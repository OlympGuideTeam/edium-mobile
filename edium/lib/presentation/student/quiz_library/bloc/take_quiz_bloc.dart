import 'dart:async';

import 'package:dio/dio.dart';
import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';
import 'package:edium/domain/usecases/library_quiz/create_attempt_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/finish_attempt_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/get_attempt_result_usecase.dart';
import 'package:edium/domain/usecases/library_quiz/submit_attempt_answer_usecase.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TakeQuizBloc extends Bloc<TakeQuizEvent, TakeQuizState> {
  final CreateAttemptUsecase _createAttempt;
  final SubmitAttemptAnswerUsecase _submitAnswer;
  final FinishAttemptUsecase _finishAttempt;
  final GetAttemptResultUsecase _getResult;
  final ITestSessionRepository? _testRepo;
  final bool isFromCourse;

  Timer? _timer;
  Timer? _debounceTimer;
  String? _sessionIdForCache;

  TakeQuizBloc({
    required CreateAttemptUsecase createAttempt,
    required SubmitAttemptAnswerUsecase submitAnswer,
    required FinishAttemptUsecase finishAttempt,
    required GetAttemptResultUsecase getResult,
    ITestSessionRepository? testSessionRepo,
    this.isFromCourse = false,
  })  : _createAttempt = createAttempt,
        _submitAnswer = submitAnswer,
        _finishAttempt = finishAttempt,
        _getResult = getResult,
        _testRepo = testSessionRepo,
        super(const TakeQuizInitial()) {
    on<StartAttemptEvent>(_onStart);
    on<SetAnswerEvent>(_onSetAnswer);
    on<GoNextEvent>(_onGoNext);
    on<GoPrevEvent>(_onGoPrev);
    on<JumpToQuestionEvent>(_onJump);
    on<FinishAttemptEvent>(_onFinish);
    on<TimerTickEvent>(_onTimerTick);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _debounceTimer?.cancel();
    return super.close();
  }

  void _startTimer(int totalSec) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final remaining = totalSec - t.tick;
      if (remaining <= 0) {
        t.cancel();
        add(const TimerTickEvent(0));
      } else {
        add(TimerTickEvent(remaining));
      }
    });
  }

  Future<void> _onStart(
    StartAttemptEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    emit(const TakeQuizLoading());
    _sessionIdForCache = event.useCache ? event.sessionId : null;
    try {
      QuizAttempt attempt;
      Map<String, Map<String, dynamic>?> answers = {};

      if (event.useCache && _testRepo != null) {
        final cached = await _testRepo!.readCachedAttempt(event.sessionId);
        final now = DateTime.now();
        if (cached != null && !cached.isExpired(now)) {
          attempt = QuizAttempt(
            attemptId: cached.attemptId,
            questions: cached.questions.map((e) => e.toEntity()).toList(),
          );
          answers = {
            for (final e in cached.answers.entries)
              e.key: Map<String, dynamic>.from(e.value),
          };
        } else {
          final res = await _testRepo!
              .startOrResumeAttempt(sessionId: event.sessionId);
          attempt = res.attempt;
        }
      } else {
        attempt = await _createAttempt(event.sessionId);
      }

      int? remainingSeconds;
      if (event.totalTimeLimitSec != null) {
        remainingSeconds = event.totalTimeLimitSec!;
        _startTimer(remainingSeconds);
      }

      emit(TakeQuizInProgress(
        attempt: attempt,
        quizTitle: event.quizTitle,
        currentIndex: 0,
        answers: answers,
        remainingSeconds: remainingSeconds,
      ));
    } catch (e) {
      emit(TakeQuizError(_humanMessage(e)));
    }
  }

  Future<void> _onSetAnswer(
    SetAnswerEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    final updated = Map<String, Map<String, dynamic>?>.from(s.answers);
    updated[s.currentQuestion.id] = event.answerData;
    emit(s.copyWith(answers: updated));

    final sid = _sessionIdForCache;
    if (sid == null || _testRepo == null) return;

    final isTextAnswer = event.answerData.containsKey('text');
    if (isTextAnswer) {

      _debounceTimer?.cancel();
      final questionId = s.currentQuestion.id;
      final attemptId = s.attempt.attemptId;
      final answerData = event.answerData;
      _debounceTimer = Timer(const Duration(seconds: 2), () {
        _testRepo!.submitAnswer(
          attemptId: attemptId,
          sessionId: sid,
          questionId: questionId,
          answerData: answerData,
        );
      });
    } else {
      await _testRepo!.submitAnswer(
        attemptId: s.attempt.attemptId,
        sessionId: sid,
        questionId: s.currentQuestion.id,
        answerData: event.answerData,
      );
    }
  }

  Future<void> _onGoNext(
    GoNextEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;

    await _submitCurrentIfAnswered(s);

    if (s.isLastQuestion) {
      add(const FinishAttemptEvent());
    } else {
      emit(s.copyWith(currentIndex: s.currentIndex + 1));
    }
  }

  void _onGoPrev(GoPrevEvent event, Emitter<TakeQuizState> emit) {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    if (s.currentIndex == 0) return;
    emit(s.copyWith(currentIndex: s.currentIndex - 1));
  }

  Future<void> _onJump(
    JumpToQuestionEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    final total = s.attempt.questions.length;
    if (event.index < 0 || event.index >= total) return;
    if (event.index == s.currentIndex) return;

    await _submitCurrentIfAnswered(s);
    emit(s.copyWith(currentIndex: event.index));
  }

  Future<void> _onFinish(
    FinishAttemptEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    _timer?.cancel();

    await _submitCurrentIfAnswered(s);

    emit(const TakeQuizFinishing());
    bool finished = false;
    try {
      final sid = _sessionIdForCache;
      if (sid != null && _testRepo != null) {
        await _testRepo!.finishAttempt(
          attemptId: s.attempt.attemptId,
          sessionId: sid,
        );
        emit(TakeQuizSubmitted(attemptId: s.attempt.attemptId));
        return;
      }
      await _finishAttempt(s.attempt.attemptId);
      finished = true;
      final result = await _getResult(s.attempt.attemptId);
      emit(TakeQuizCompleted(
        result: result,
        maxPossibleScore: s.attempt.maxPossibleScore,
        quizTitle: s.quizTitle,
        questions: s.attempt.questions,
      ));
    } catch (e) {
      if (finished && isFromCourse) {
        emit(TakeQuizSubmitted(attemptId: s.attempt.attemptId));
      } else {
        emit(TakeQuizError(_humanMessage(e)));
      }
    }
  }

  void _onTimerTick(TimerTickEvent event, Emitter<TakeQuizState> emit) {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    if (event.remainingSeconds <= 0) {
      _timer?.cancel();
      add(const FinishAttemptEvent());
    } else {
      emit(s.copyWith(remainingSeconds: event.remainingSeconds));
    }
  }

  Future<void> _submitCurrentIfAnswered(TakeQuizInProgress s) async {
    final answer = s.answers[s.currentQuestion.id];
    if (answer == null) return;

    _debounceTimer?.cancel();
    _debounceTimer = null;
    final sid = _sessionIdForCache;
    try {
      if (sid != null && _testRepo != null) {
        await _testRepo!.submitAnswer(
          attemptId: s.attempt.attemptId,
          sessionId: sid,
          questionId: s.currentQuestion.id,
          answerData: answer,
        );
      } else {
        await _submitAnswer(
          attemptId: s.attempt.attemptId,
          questionId: s.currentQuestion.id,
          answerData: answer,
        );
      }
    } catch (_) {

    }
  }


  String _humanMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final code = data['error'] as String?;
        switch (code) {
          case 'SESSION_NOT_STARTED':
            return 'Тест ещё не открыт';
          case 'SESSION_DEADLINE_PASSED':
            return 'Срок сдачи истёк';
          case 'SESSION_NOT_ACTIVE':
            return 'Тест недоступен';
          case 'ATTEMPT_EXPIRED':
            return 'Время попытки истекло';
        }
        final desc = data['description'] as String?;
        if (desc != null && desc.isNotEmpty) return desc;
      }
    }
    return error.toString();
  }
}
