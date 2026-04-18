import 'dart:async';

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
  Timer? _timer;

  TakeQuizBloc({
    required CreateAttemptUsecase createAttempt,
    required SubmitAttemptAnswerUsecase submitAnswer,
    required FinishAttemptUsecase finishAttempt,
    required GetAttemptResultUsecase getResult,
  })  : _createAttempt = createAttempt,
        _submitAnswer = submitAnswer,
        _finishAttempt = finishAttempt,
        _getResult = getResult,
        super(const TakeQuizInitial()) {
    on<StartAttemptEvent>(_onStart);
    on<SetAnswerEvent>(_onSetAnswer);
    on<GoNextEvent>(_onGoNext);
    on<GoPrevEvent>(_onGoPrev);
    on<FinishAttemptEvent>(_onFinish);
    on<TimerTickEvent>(_onTimerTick);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
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
    try {
      final attempt = await _createAttempt(event.sessionId);

      int? remainingSeconds;
      if (event.totalTimeLimitSec != null) {
        remainingSeconds = event.totalTimeLimitSec!;
        _startTimer(remainingSeconds);
      }

      emit(TakeQuizInProgress(
        attempt: attempt,
        quizTitle: event.quizTitle,
        currentIndex: 0,
        answers: {},
        remainingSeconds: remainingSeconds,
      ));
    } catch (e) {
      emit(TakeQuizError(e.toString()));
    }
  }

  void _onSetAnswer(SetAnswerEvent event, Emitter<TakeQuizState> emit) {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    final updated = Map<String, Map<String, dynamic>?>.from(s.answers);
    updated[s.currentQuestion.id] = event.answerData;
    emit(s.copyWith(answers: updated));
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

  Future<void> _onFinish(
    FinishAttemptEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    _timer?.cancel();

    await _submitCurrentIfAnswered(s);

    emit(const TakeQuizFinishing());
    try {
      await _finishAttempt(s.attempt.attemptId);
      final result = await _getResult(s.attempt.attemptId);
      emit(TakeQuizCompleted(
        result: result,
        maxPossibleScore: s.attempt.maxPossibleScore,
      ));
    } catch (e) {
      emit(TakeQuizError(e.toString()));
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
    try {
      await _submitAnswer(
        attemptId: s.attempt.attemptId,
        questionId: s.currentQuestion.id,
        answerData: answer,
      );
    } catch (_) {
      // upsert — best effort, don't block navigation
    }
  }
}
