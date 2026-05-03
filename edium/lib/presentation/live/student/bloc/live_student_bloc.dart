import 'dart:async';

import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/live_ws_event.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/student/bloc/live_student_event.dart';
import 'package:edium/presentation/live/student/bloc/live_student_state.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LiveStudentBloc extends Bloc<LiveStudentEvent, LiveStudentState> {
  final ILiveRepository _repo;
  final LiveWsService _ws;

  String? _sessionId;
  String _quizTitle = '';
  int _questionCount = 0;
  int? _classmatesTotal;
  Map<String, String> _roster = {};

  // In-memory state for question transitions
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
    _quizTitle = event.quizTitle;
    _questionCount = event.questionCount;
    _classmatesTotal = null;
    _roster = {};
    emit(LiveStudentConnecting());

    try {
      var moduleId = event.moduleId;
      if (moduleId == null || moduleId.isEmpty) {
        try {
          final meta = await _repo.getLiveSession(event.sessionId);
          moduleId = meta.moduleId;
          if (_quizTitle.isEmpty && meta.quizTitle.isNotEmpty) {
            _quizTitle = meta.quizTitle;
          }
          if (_questionCount <= 0 && meta.questionCount > 0) {
            _questionCount = meta.questionCount;
          }
        } catch (e) {
          debugPrint('[LiveStudentBloc] getLiveSession (module_id): $e');
        }
      }

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

  void _onWsEvent(
    LiveStudentWsEvent event,
    Emitter<LiveStudentState> emit,
  ) {
    final e = event.event;

    switch (e) {
      case LiveStateSnapshot(:final questionTotal):
        _questionTotal = questionTotal;
        _applySnapshot(e, emit);

      case LiveLobbyParticipantJoined(:final attemptId, :final userId, :final name):
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
        // Another student was kicked — no action needed for this student

      case LiveWsDisconnected():
        if (state is! LiveStudentKicked && state is! LiveStudentCompleted) {
          emit(LiveStudentError('Соединение прервано'));
        }

      case LiveWsError():
        // Non-fatal errors (e.g. ALREADY_ANSWERED) — ignore for now

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
        if (snap.currentQuestion != null) {
          _currentQuestion = snap.currentQuestion;
          _questionIndex = snap.questionIndex ?? 1;
          emit(LiveStudentQuestionActive(
            question: snap.currentQuestion!,
            questionIndex: snap.questionIndex ?? 1,
            questionTotal: snap.questionTotal,
            deadlineAt: snap.questionDeadlineAt ?? DateTime.now(),
            timeLimitSec: snap.timeLimitSec ?? 30,
            myAnswer: snap.myAnswer,
          ));
        }

      case LivePhase.questionLocked:
        if (_currentQuestion != null && snap.lastQuestionLocked != null) {
          final locked = snap.lastQuestionLocked!;
          emit(LiveStudentQuestionLocked(
            question: _currentQuestion!,
            questionIndex: _questionIndex,
            questionTotal: _questionTotal,
            correctAnswer: locked.correctAnswer,
            stats: locked.stats,
            myResult: locked.myResult,
            wordCloud: locked.wordCloud,
            myAnswer: _myLastAnswer,
          ));
        }

      case LivePhase.completed:
        emit(LiveStudentCompleted());
    }
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
    // Optimistically mark as answered
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
    if (sid == null) return;
    emit(LiveStudentResultsLoading());
    try {
      final results = await _repo.getLiveResultsStudent(sid);
      emit(LiveStudentResultsLoaded(results));
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
