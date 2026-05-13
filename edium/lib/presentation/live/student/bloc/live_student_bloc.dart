import 'dart:async';

import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/live_ws_event.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/student/bloc/live_student_event.dart';
import 'package:edium/presentation/live/student/bloc/live_student_state.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveStudentBloc extends Bloc<LiveStudentEvent, LiveStudentState> {
  final ILiveRepository _repo;
  final LiveWsService _ws;

  String? _sessionId;
  String? _attemptId;
  String? _moduleId;
  String _quizTitle = '';
  int _questionCount = 0;
  int? _classmatesTotal;
  Map<String, String> _roster = {};


  LiveQuestion? _currentQuestion;
  int _questionIndex = 0;
  int _questionTotal = 0;
  Map<String, dynamic>? _myLastAnswer;

  StreamSubscription<LiveWsEvent>? _wsSub;

  LiveStudentBloc({
    required ILiveRepository repo,
    required LiveWsService ws,
  })  : _repo = repo,
        _ws = ws,
        super(LiveStudentInitial()) {
    on<LiveStudentStart>(_onStart);
    on<LiveStudentWsEvent>(_onWsEvent);
    on<LiveStudentSubmitAnswer>(_onSubmitAnswer);
    on<LiveStudentLoadResults>(_onLoadResults);
    on<LiveStudentDispose>(_onDispose);
  }

  Future<void> _onStart(
    LiveStudentStart event,
    Emitter<LiveStudentState> emit,
  ) async {
    _sessionId = event.sessionId;
    _attemptId = event.attemptId;
    _moduleId = null;
    _quizTitle = event.quizTitle;
    _questionCount = event.questionCount;
    _classmatesTotal = null;
    _roster = {};
    emit(LiveStudentConnecting());

    try {
      LiveSessionMeta? metaFromApi;
      try {
        metaFromApi = await _repo.getLiveSession(event.sessionId);
        if (_quizTitle.isEmpty && metaFromApi.quizTitle.isNotEmpty) {
          _quizTitle = metaFromApi.quizTitle;
        }
        if (_questionCount <= 0 && metaFromApi.questionCount > 0) {
          _questionCount = metaFromApi.questionCount;
        }
      } catch (e) {
        debugPrint('[LiveStudentBloc] getLiveSession: $e');
      }

      var moduleId = event.moduleId;
      if ((moduleId == null || moduleId.isEmpty) && metaFromApi != null) {
        moduleId = metaFromApi.moduleId;
      }
      _moduleId = (moduleId != null && moduleId.isNotEmpty) ? moduleId : null;

      if (moduleId != null && moduleId.isNotEmpty) {
        try {
          final members = await _repo.getModuleRoster(moduleId);
          _roster = {for (final m in members) m.userId: m.name};
          _classmatesTotal = members.length;
          debugPrint(
            '[LiveStudentBloc] roster loaded: ${_roster.length} classmates',
          );
        } catch (e) {
          debugPrint('[LiveStudentBloc] roster unavailable: $e');
        }
      } else {
        debugPrint(
          '[LiveStudentBloc] roster skipped: no module_id (resolve/join/meta)',
        );
      }

      if (metaFromApi != null &&
          metaFromApi.phase == LivePhase.completed &&
          event.attemptId.isNotEmpty) {
        emit(LiveStudentCompleted());
        return;
      }

      if (event.wsToken.isEmpty) {
        if (event.attemptId.isNotEmpty) {
          emit(LiveStudentCompleted());
          return;
        }
        emit(LiveStudentError('Не удалось подключиться к квизу'));
        return;
      }

      await _ws.connect(event.sessionId, event.wsToken);
      _wsSub = _ws.events.listen(
        (wsEvent) => add(LiveStudentWsEvent(wsEvent)),
      );
    } catch (e) {
      emit(LiveStudentError('Ошибка подключения: $e'));
    }
  }

  String _resolveName(String? userId, String wsName) {
    if (userId != null) {
      final rosterName = _roster[userId];
      if (rosterName != null && rosterName.isNotEmpty) return rosterName;
    }
    return wsName.isNotEmpty ? wsName : userId ?? '?';
  }


  Future<void> _ensureRosterBeforeResults() async {
    final mid = _moduleId;
    if (_roster.isNotEmpty || mid == null || mid.isEmpty) return;
    try {
      final members = await _repo.getModuleRoster(mid);
      _roster = {for (final m in members) m.userId: m.name};
      _classmatesTotal = members.length;
      debugPrint(
        '[LiveStudentBloc] roster loaded before results: ${_roster.length}',
      );
    } catch (e) {
      debugPrint('[LiveStudentBloc] roster before results unavailable: $e');
    }
  }

  List<LiveLobbyParticipant> _resolveParticipants(
    List<LiveLobbyParticipant> raw,
  ) =>
      raw
          .map(
            (p) => LiveLobbyParticipant(
              attemptId: p.attemptId,
              userId: p.userId,
              name: _resolveName(p.userId, p.name),
            ),
          )
          .toList();

  Future<void> _onWsEvent(
    LiveStudentWsEvent event,
    Emitter<LiveStudentState> emit,
  ) async {
    final e = event.event;

    switch (e) {
      case LiveStateSnapshot(:final questionTotal):
        _questionTotal = questionTotal;
        _applySnapshot(e, emit);
        if (state is LiveStudentLobby && _roster.isEmpty) {
          final s = state as LiveStudentLobby;
          final userIds = s.participants
              .where((p) => p.userId != null && p.userId!.isNotEmpty)
              .map((p) => p.userId!)
              .toSet()
              .toList();
          if (userIds.isNotEmpty) {
            try {
              final members = await _repo.getUsersRoster(userIds);
              if (members.isNotEmpty) {
                _roster = {for (final m in members) m.userId: m.name};
                if (state is LiveStudentLobby) {
                  emit((state as LiveStudentLobby).copyWith(
                    participants: _resolveParticipants(
                      (state as LiveStudentLobby).participants,
                    ),
                  ));
                }
              }
            } catch (err) {
              debugPrint('[LiveStudentBloc] getUsersRoster: $err');
            }
          }
        }

      case LiveLobbyParticipantJoined(:final attemptId, :final userId, :final name):
        final needsFetch = userId != null &&
            userId.isNotEmpty &&
            name.isEmpty &&
            !_roster.containsKey(userId);
        if (needsFetch) {
          try {
            final members = await _repo.getUsersRoster([userId]);
            for (final m in members) {
              _roster[m.userId] = m.name;
            }
          } catch (err) {
            debugPrint('[LiveStudentBloc] getUsersRoster for joined: $err');
          }
        }
        if (state is LiveStudentLobby) {
          final s = state as LiveStudentLobby;
          final updated = List<LiveLobbyParticipant>.from(s.participants)
            ..removeWhere((p) => p.attemptId == attemptId)
            ..add(LiveLobbyParticipant(
              attemptId: attemptId,
              userId: userId,
              name: _resolveName(userId, name),
            ));
          emit(s.copyWith(participants: updated));
        }

      case LiveLobbyParticipantLeft(:final attemptId):
        if (state is LiveStudentLobby) {
          final s = state as LiveStudentLobby;
          final updated = s.participants
              .where((p) => p.attemptId != attemptId)
              .toList();
          emit(s.copyWith(participants: updated));
        }

      case LiveQuizStarted():
        break;

      case LiveQuestionStarted(
          :final question,
          :final questionIndex,
          :final deadlineAt,
          :final timeLimitSec,
        ):
        _currentQuestion = question;
        _questionIndex = questionIndex;
        _myLastAnswer = null;
        emit(LiveStudentQuestionActive(
          question: question,
          questionIndex: questionIndex,
          questionTotal: _questionTotal,
          deadlineAt: deadlineAt,
          timeLimitSec: timeLimitSec,
        ));

      case LiveQuestionLocked(
          :final correctAnswer,
          :final stats,
          :final myResult,
          :final wordCloud,
        ):
        if (_currentQuestion != null) {
          emit(LiveStudentQuestionLocked(
            question: _currentQuestion!,
            questionIndex: _questionIndex,
            questionTotal: _questionTotal,
            correctAnswer: correctAnswer,
            stats: stats,
            myResult: myResult,
            wordCloud: wordCloud,
            myAnswer: _myLastAnswer,
          ));
        }

      case LiveQuizCompleted():
        emit(LiveStudentCompleted());

      case LiveYouWereKicked():
        emit(LiveStudentKicked());

      case LiveParticipantKicked():


      case LiveWsDisconnected():
        if (state is! LiveStudentKicked &&
            state is! LiveStudentCompleted &&
            state is! LiveStudentResultsLoading &&
            state is! LiveStudentResultsLoaded) {
          emit(LiveStudentError('Соединение прервано'));
        }

      case LiveWsError():


      default:
        break;
    }
  }

  void _applySnapshot(
    LiveStateSnapshot snap,
    Emitter<LiveStudentState> emit,
  ) {
    _questionTotal = snap.questionTotal;

    switch (snap.phase) {
      case LivePhase.pending:
      case LivePhase.lobby:
        emit(LiveStudentLobby(
          quizTitle: _quizTitle,
          questionCount: _questionCount > 0 ? _questionCount : snap.questionTotal,
          participants: _resolveParticipants(snap.lobbyParticipants),
          classmatesTotal: _classmatesTotal,
        ));

      case LivePhase.questionActive:
        final activeQuestion = snap.currentQuestion ?? _currentQuestion;
        if (activeQuestion != null) {
          _currentQuestion = activeQuestion;
          _questionIndex = snap.questionIndex ?? _questionIndex;
          emit(LiveStudentQuestionActive(
            question: activeQuestion,
            questionIndex: _questionIndex,
            questionTotal: snap.questionTotal,
            deadlineAt: snap.questionDeadlineAt ?? DateTime.now(),
            timeLimitSec: snap.timeLimitSec ?? 30,
            myAnswer: snap.myAnswer,
          ));
        }

      case LivePhase.questionLocked:
        final lockedQuestion = snap.currentQuestion ?? _currentQuestion;
        if (lockedQuestion != null) {
          _currentQuestion = lockedQuestion;
          if (snap.questionIndex != null) _questionIndex = snap.questionIndex!;
          final locked = snap.lastQuestionLocked;
          emit(LiveStudentQuestionLocked(
            question: lockedQuestion,
            questionIndex: _questionIndex,
            questionTotal: _questionTotal,
            correctAnswer: locked?.correctAnswer ?? const LiveCorrectAnswer({}),
            stats: locked?.stats ?? _emptyStats(lockedQuestion),
            myResult: locked?.myResult,
            wordCloud: locked?.wordCloud,
            myAnswer: _myLastAnswer,
          ));
        }

      case LivePhase.completed:
        emit(LiveStudentCompleted());
    }
  }

  LiveQuestionStats _emptyStats(LiveQuestion q) {
    if (q.type == QuestionType.singleChoice ||
        q.type == QuestionType.multiChoice) {
      return LiveChoiceStats(
          answeredCount: 0, correctCount: 0, distribution: []);
    }
    return LiveBinaryStats(
        answeredCount: 0, correctCount: 0, incorrectCount: 0);
  }

  Future<void> _onSubmitAnswer(
    LiveStudentSubmitAnswer event,
    Emitter<LiveStudentState> emit,
  ) async {
    _myLastAnswer = event.answerData;
    _ws.send({
      'type': 'student.submit_answer',
      'data': {
        'question_id': event.questionId,
        'answer_data': event.answerData,
      },
    });

    if (state is LiveStudentQuestionActive) {
      final s = state as LiveStudentQuestionActive;
      emit(s.copyWith(myAnswer: event.answerData));
    }
  }

  Future<void> _onLoadResults(
    LiveStudentLoadResults event,
    Emitter<LiveStudentState> emit,
  ) async {
    final sid = _sessionId;
    final aid = _attemptId;
    if (sid == null || aid == null) return;
    emit(LiveStudentResultsLoading());
    try {
      await _ensureRosterBeforeResults();

      LiveResultsStudent raw;
      const maxRetries = 4;
      var attempt = 0;
      while (true) {
        try {
          raw = await _repo.getLiveResultsStudent(sid, aid);
          break;
        } on ApiException catch (e) {
          if (e.statusCode == 409 && attempt < maxRetries - 1) {
            attempt++;
            debugPrint('[LiveStudentBloc] results 409, retry $attempt/$maxRetries');
            await Future.delayed(const Duration(milliseconds: 1500));
            continue;
          }
          rethrow;
        }
      }

      final resolvedTop = raw.top
          .map((row) => LiveLeaderboardRow(
                position: row.position,
                attemptId: row.attemptId,
                userId: row.userId,
                name: _resolveName(row.userId, row.name),
                score: row.score,
                isMe: row.isMe,
              ))
          .toList();
      final resolved = LiveResultsStudent(
        myPosition: raw.myPosition,
        totalParticipants: raw.totalParticipants,
        myScore: raw.myScore,
        maxScore: raw.maxScore,
        correctCount: raw.correctCount,
        questionsCount: raw.questionsCount,
        top: resolvedTop,
      );

      LiveAttemptReview? review;
      try {
        review = await _repo.getAttemptReview(aid);
      } catch (e) {
        debugPrint('[LiveStudentBloc] review load failed: $e');
      }

      emit(LiveStudentResultsLoaded(resolved, review: review));
    } catch (e) {
      emit(LiveStudentError(e.toString()));
    }
  }

  void _onDispose(LiveStudentDispose event, Emitter<LiveStudentState> emit) {
    _wsSub?.cancel();
    _ws.disconnect();
  }

  @override
  Future<void> close() async {
    await _wsSub?.cancel();
    await _ws.disconnect();
    return super.close();
  }
}
