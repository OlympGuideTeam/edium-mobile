import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/live_ws_event.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_event.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_state.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveTeacherBloc extends Bloc<LiveTeacherEvent, LiveTeacherState> {
  final ILiveRepository _repo;
  final LiveWsService _ws;

  String? _sessionId;
  String? _moduleId;
  String _quizTitle = '';
  int _questionCount = 0;
  String? _joinCode;

  Map<String, String> _roster = {};

  LiveQuestion? _currentQuestion;
  int _questionIndex = 0;
  int _questionTotal = 0;

  List<LiveLobbyParticipant> _lobbyParticipants = [];
  Map<String, LiveTeacherParticipantAnswer> _answeredMap = {};

  StreamSubscription<LiveWsEvent>? _wsSub;

  LiveTeacherBloc({
    required ILiveRepository repo,
    required LiveWsService ws,
  })  : _repo = repo,
        _ws = ws,
        super(LiveTeacherInitial()) {
    on<LiveTeacherLoad>(_onLoad);
    on<LiveTeacherWsEvent>(_onWsEvent);
    on<LiveTeacherStartLobby>(_onStartLobby);
    on<LiveTeacherStartQuiz>(_onStartQuiz);
    on<LiveTeacherNextQuestion>(_onNextQuestion);
    on<LiveTeacherKickParticipant>(_onKick);
    on<LiveTeacherLoadResults>(_onLoadResults);
    on<LiveTeacherDispose>(_onDispose);
  }

  Future<void> _onLoad(
    LiveTeacherLoad event,
    Emitter<LiveTeacherState> emit,
  ) async {
    _sessionId = event.sessionId;
    _moduleId = event.moduleId;
    _quizTitle = event.quizTitle;
    _questionCount = event.questionCount;
    _questionTotal = event.questionCount;
    emit(LiveTeacherConnecting());

    debugPrint('[LiveTeacherBloc] _onLoad sessionId=${event.sessionId}');

    try {
      final start = await _repo.startLiveSession(event.sessionId);
      _joinCode = start.joinCode;
      debugPrint('[LiveTeacherBloc] startLiveSession ok, joinCode=${start.joinCode}, wsTokenLen=${start.wsToken.length}');

      final moduleId = event.moduleId;
      if (moduleId != null && moduleId.isNotEmpty) {
        try {
          final members = await _repo.getModuleRoster(moduleId);
          _roster = {for (final m in members) m.userId: m.name};
          debugPrint('[LiveTeacherBloc] roster loaded: ${_roster.length} members');
        } catch (e) {
          debugPrint('[LiveTeacherBloc] roster unavailable: $e');
        }
      }

      await _ws.connect(event.sessionId, start.wsToken);
      debugPrint('[LiveTeacherBloc] WS connected, subscribing to events');
      _wsSub = _ws.events.listen(
        (wsEvent) {
          debugPrint('[LiveTeacherBloc] WS event received: ${wsEvent.runtimeType}');
          add(LiveTeacherWsEvent(wsEvent));
        },
      );
    } on ApiException catch (e, st) {
      debugPrint('[LiveTeacherBloc] connect error: $e\n$st');
      if (e.code == 'SESSION_COMPLETED') {
        emit(LiveTeacherCompleted());
        return;
      }
      emit(LiveTeacherError('Ошибка подключения: ${e.message}'));
    } catch (e, st) {
      debugPrint('[LiveTeacherBloc] connect error: $e\n$st');
      emit(LiveTeacherError('Ошибка подключения: $e'));
    }
  }

  void _onWsEvent(
    LiveTeacherWsEvent event,
    Emitter<LiveTeacherState> emit,
  ) {
    final e = event.event;

    switch (e) {
      case LiveStateSnapshot(:final questionTotal, :final lobbyParticipants):
        if (questionTotal > 0) _questionTotal = questionTotal;
        _lobbyParticipants = lobbyParticipants;
        _applySnapshot(e, emit);

      case LiveLobbyParticipantJoined(:final attemptId, :final userId, :final name):
        _lobbyParticipants = [
          ..._lobbyParticipants.where((p) => p.attemptId != attemptId),
          LiveLobbyParticipant(
            attemptId: attemptId,
            userId: userId,
            name: _resolveName(userId, name),
          ),
        ];
        if (state is LiveTeacherLobby) {
          final s = state as LiveTeacherLobby;
          emit(s.copyWith(participants: _lobbyParticipants));
        }

      case LiveLobbyParticipantLeft(:final attemptId):
        _lobbyParticipants =
            _lobbyParticipants.where((p) => p.attemptId != attemptId).toList();
        if (state is LiveTeacherLobby) {
          final s = state as LiveTeacherLobby;
          emit(s.copyWith(participants: _lobbyParticipants));
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
        _answeredMap = {};
        final pending = _lobbyParticipants.map((p) => p.attemptId).toList();
        emit(LiveTeacherQuestionActive(
          question: question,
          questionIndex: questionIndex,
          questionTotal: _questionTotal,
          deadlineAt: deadlineAt,
          timeLimitSec: timeLimitSec,
          participants: List.from(_lobbyParticipants),
          answeredMap: {},
          pendingAttemptIds: pending,
        ));

      case LiveParticipantAnswered(:final attemptId, :final isCorrect, :final timeTakenMs):
        _answeredMap = {
          ..._answeredMap,
          attemptId: LiveTeacherParticipantAnswer(
            isCorrect: isCorrect,
            timeTakenMs: timeTakenMs,
          ),
        };
        if (state is LiveTeacherQuestionActive) {
          final s = state as LiveTeacherQuestionActive;
          final pending =
              s.pendingAttemptIds.where((id) => id != attemptId).toList();
          emit(s.copyWith(
            answeredMap: Map.from(_answeredMap),
            pendingAttemptIds: pending,
          ));
        }

      case LiveQuestionStatsTick(:final stats):
        if (state is LiveTeacherQuestionActive) {
          final s = state as LiveTeacherQuestionActive;
          emit(s.copyWith(stats: stats));
        }

      case LiveQuestionLocked(:final correctAnswer, :final stats):
        if (_currentQuestion != null) {
          final fillAtLock = switch (state) {
            LiveTeacherQuestionActive(:final deadlineAt, :final timeLimitSec) =>
              _timerFillFraction(deadlineAt, timeLimitSec),
            _ => 1.0,
          };
          emit(LiveTeacherQuestionLocked(
            question: _currentQuestion!,
            questionIndex: _questionIndex,
            questionTotal: _questionTotal,
            correctAnswer: correctAnswer,
            stats: stats,
            participants: List.from(_lobbyParticipants),
            answeredMap: Map.from(_answeredMap),
            timerFillAtLock: fillAtLock,
          ));
        }

      case LiveQuizCompleted():
        emit(LiveTeacherCompleted());

      case LiveParticipantKicked(:final attemptId):
        _lobbyParticipants =
            _lobbyParticipants.where((p) => p.attemptId != attemptId).toList();

      case LiveWsDisconnected():
        if (state is! LiveTeacherCompleted &&
            state is! LiveTeacherResultsLoading &&
            state is! LiveTeacherResultsLoaded) {
          emit(LiveTeacherError('Соединение прервано'));
        }

      default:
        break;
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
      debugPrint(
        '[LiveTeacherBloc] roster loaded before results: ${_roster.length}',
      );
    } catch (e) {
      debugPrint('[LiveTeacherBloc] roster before results unavailable: $e');
    }
  }


  double _timerFillFraction(DateTime deadlineAt, int timeLimitSec) {
    if (timeLimitSec <= 0) return 1.0;
    final started = deadlineAt.subtract(Duration(seconds: timeLimitSec));
    final elapsedMs = DateTime.now().difference(started).inMilliseconds;
    return (elapsedMs / (timeLimitSec * 1000)).clamp(0.0, 1.0);
  }

  void _applySnapshot(
    LiveStateSnapshot snap,
    Emitter<LiveTeacherState> emit,
  ) {
    if (snap.questionTotal > 0) _questionTotal = snap.questionTotal;

    switch (snap.phase) {
      case LivePhase.pending:
        emit(LiveTeacherPending(
          quizTitle: _quizTitle,
          questionCount: _questionCount,
        ));

      case LivePhase.lobby:
        final resolvedParticipants = snap.lobbyParticipants
            .map((p) => LiveLobbyParticipant(
                  attemptId: p.attemptId,
                  userId: p.userId,
                  name: _resolveName(p.userId, p.name),
                ))
            .toList();
        _lobbyParticipants = resolvedParticipants;
        emit(LiveTeacherLobby(
          quizTitle: _quizTitle,
          questionCount: _questionCount,
          joinCode: _joinCode,
          participants: resolvedParticipants,
          roster: Map.from(_roster),
        ));

      case LivePhase.questionActive:
        final activeQuestion = snap.currentQuestion ?? _currentQuestion;
        if (activeQuestion != null) {
          _currentQuestion = activeQuestion;
          _questionIndex = snap.questionIndex ?? _questionIndex;
          _answeredMap = {};
          final pending =
              _lobbyParticipants.map((p) => p.attemptId).toList();
          emit(LiveTeacherQuestionActive(
            question: activeQuestion,
            questionIndex: _questionIndex,
            questionTotal: snap.questionTotal,
            deadlineAt: snap.questionDeadlineAt ?? DateTime.now(),
            timeLimitSec: snap.timeLimitSec ?? 30,
            participants: List.from(_lobbyParticipants),
            answeredMap: {},
            pendingAttemptIds: pending,
          ));
        }

      case LivePhase.questionLocked:
        final lockedQuestion = snap.currentQuestion ?? _currentQuestion;
        if (lockedQuestion != null) {
          _currentQuestion = lockedQuestion;
          if (snap.questionIndex != null) _questionIndex = snap.questionIndex!;
          final locked = snap.lastQuestionLocked;
          emit(LiveTeacherQuestionLocked(
            question: lockedQuestion,
            questionIndex: _questionIndex,
            questionTotal: _questionTotal,
            correctAnswer: locked?.correctAnswer ?? const LiveCorrectAnswer({}),
            stats: locked?.stats ?? _emptyStats(lockedQuestion),
            participants: List.from(_lobbyParticipants),
            answeredMap: Map.from(_answeredMap),
            timerFillAtLock: 1.0,
          ));
        }

      case LivePhase.completed:
        emit(LiveTeacherCompleted());
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

  void _onStartLobby(
      LiveTeacherStartLobby event, Emitter<LiveTeacherState> emit) {
    _ws.send({'type': 'teacher.start_lobby', 'data': {}});

  }

  void _onStartQuiz(
      LiveTeacherStartQuiz event, Emitter<LiveTeacherState> emit) {
    _ws.send({'type': 'teacher.start_quiz', 'data': {}});
  }

  void _onNextQuestion(
      LiveTeacherNextQuestion event, Emitter<LiveTeacherState> emit) {
    _ws.send({'type': 'teacher.next_question', 'data': {}});
  }

  void _onKick(
      LiveTeacherKickParticipant event, Emitter<LiveTeacherState> emit) {
    _ws.send({
      'type': 'teacher.kick_participant',
      'data': {'attempt_id': event.attemptId},
    });
  }

  Future<void> _onLoadResults(
    LiveTeacherLoadResults event,
    Emitter<LiveTeacherState> emit,
  ) async {
    final sid = _sessionId;
    if (sid == null) return;
    emit(LiveTeacherResultsLoading());
    try {
      await _ensureRosterBeforeResults();
      final results = await _repo.getLiveResultsTeacher(sid);
      final leaderboard = results.leaderboard.map((row) {
        final resolved = row.userId != null ? _roster[row.userId!] : null;
        if (resolved != null && resolved.isNotEmpty) {
          return LiveResultsTeacherAttempt(
            position: row.position,
            attemptId: row.attemptId,
            userId: row.userId,
            name: resolved,
            score: row.score,
            maxScore: row.maxScore,
            correctCount: row.correctCount,
            answers: row.answers,
          );
        }
        return row;
      }).toList();
      emit(LiveTeacherResultsLoaded(LiveResultsTeacher(
        questions: results.questions,
        leaderboard: leaderboard,
      )));
    } catch (e) {
      emit(LiveTeacherError(e.toString()));
    }
  }

  void _onDispose(LiveTeacherDispose event, Emitter<LiveTeacherState> emit) {
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
