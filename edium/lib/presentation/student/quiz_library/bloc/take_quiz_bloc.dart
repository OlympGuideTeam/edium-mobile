import 'dart:async';

import 'package:edium/domain/entities/quiz_session.dart';
import 'package:edium/domain/repositories/quiz_session_repository.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/complete_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/start_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/submit_answer_usecase.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/take_quiz_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TakeQuizBloc extends Bloc<TakeQuizEvent, TakeQuizState> {
  final StartQuizUsecase _startSession;
  final SubmitAnswerUsecase _submitAnswer;
  final CompleteQuizUsecase _completeSession;
  final GetQuizzesUsecase _getQuizzes;
  final IQuizSessionRepository _sessionRepo;
  Timer? _timer;

  TakeQuizBloc({
    required StartQuizUsecase startSession,
    required SubmitAnswerUsecase submitAnswer,
    required CompleteQuizUsecase completeSession,
    required GetQuizzesUsecase getQuizzes,
    required IQuizSessionRepository sessionRepo,
  })  : _startSession = startSession,
        _submitAnswer = submitAnswer,
        _completeSession = completeSession,
        _getQuizzes = getQuizzes,
        _sessionRepo = sessionRepo,
        super(const TakeQuizInitial()) {
    on<StartSessionEvent>(_onStart);
    on<SetAnswerEvent>(_onSetAnswer);
    on<SubmitCurrentAnswerEvent>(_onSubmit);
    on<NextQuestionEvent>(_onNext);
    on<CompleteSessionEvent>(_onComplete);
    on<TimerTickEvent>(_onTimerTick);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _startTimer(int remainingSeconds) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final remaining = remainingSeconds - timer.tick;
      if (remaining <= 0) {
        timer.cancel();
        add(const TimerTickEvent(0));
      } else {
        add(TimerTickEvent(remaining));
      }
    });
  }

  Future<void> _onStart(
    StartSessionEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    emit(const TakeQuizLoading());
    try {
      final quizzes = await _getQuizzes(scope: 'global');
      final quiz = quizzes.firstWhere((q) => q.id == event.quizId);

      if (quiz.status.name == 'draft') {
        emit(const TakeQuizError('Этот квиз ещё не опубликован'));
        return;
      }

      QuizSession session;

      if (event.resumeSessionId != null) {
        // Resume existing session
        session = await _sessionRepo.getSession(event.resumeSessionId!);
      } else {
        // Always create a fresh session
        session = await _startSession(event.quizId);
      }

      // Calculate remaining time based on session start time
      final timeLimitMinutes = quiz.settings.timeLimitMinutes;
      int? remainingSeconds;
      if (timeLimitMinutes != null) {
        final totalSeconds = timeLimitMinutes * 60;
        final elapsed =
            DateTime.now().difference(session.startedAt).inSeconds;
        remainingSeconds = totalSeconds - elapsed;
        if (remainingSeconds <= 0) {
          // Time expired — auto-complete
          final result = await _completeSession(session.id);
          emit(TakeQuizCompleted(result));
          return;
        }
        _startTimer(remainingSeconds);
      }

      // Determine current question index from answered questions
      final answeredCount = session.answers.length;
      final currentIndex =
          answeredCount < quiz.questions.length ? answeredCount : 0;

      emit(TakeQuizInProgress(
        quiz: quiz,
        session: session,
        currentIndex: currentIndex,
        remainingSeconds: remainingSeconds,
      ));
    } catch (e) {
      emit(TakeQuizError(e.toString()));
    }
  }

  void _onSetAnswer(SetAnswerEvent event, Emitter<TakeQuizState> emit) {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    if (s.answerSubmitted) return;
    emit(s.copyWith(currentAnswer: event.answer));
  }

  Future<void> _onSubmit(
    SubmitCurrentAnswerEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    if (s.currentAnswer == null || s.answerSubmitted) return;

    final question = s.quiz.questions[s.currentIndex];
    try {
      final result = await _submitAnswer(
        sessionId: s.session.id,
        questionId: question.id,
        answer: s.currentAnswer,
      );
      emit(s.copyWith(
        answerSubmitted: true,
        lastCorrect: result.correct,
        lastExplanation: result.explanation,
        remainingSeconds: s.remainingSeconds,
      ));
    } catch (e) {
      emit(TakeQuizError(e.toString()));
    }
  }

  void _onNext(NextQuestionEvent event, Emitter<TakeQuizState> emit) {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    if (s.isLastQuestion) {
      add(const CompleteSessionEvent());
    } else {
      emit(TakeQuizInProgress(
        quiz: s.quiz,
        session: s.session,
        currentIndex: s.currentIndex + 1,
        remainingSeconds: s.remainingSeconds,
      ));
    }
  }

  void _onTimerTick(TimerTickEvent event, Emitter<TakeQuizState> emit) {
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    if (event.remainingSeconds <= 0) {
      _timer?.cancel();
      add(const CompleteSessionEvent());
    } else {
      emit(s.copyWith(
        remainingSeconds: event.remainingSeconds,
        currentAnswer: s.currentAnswer,
        answerSubmitted: s.answerSubmitted,
        lastCorrect: s.lastCorrect,
        lastExplanation: s.lastExplanation,
      ));
    }
  }

  Future<void> _onComplete(
    CompleteSessionEvent event,
    Emitter<TakeQuizState> emit,
  ) async {
    _timer?.cancel();
    if (state is! TakeQuizInProgress) return;
    final s = state as TakeQuizInProgress;
    try {
      final result = await _completeSession(s.session.id);
      emit(TakeQuizCompleted(result));
    } catch (e) {
      emit(TakeQuizError(e.toString()));
    }
  }
}
