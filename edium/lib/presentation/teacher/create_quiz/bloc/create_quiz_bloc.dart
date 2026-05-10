import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_event.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateQuizBloc extends Bloc<CreateQuizEvent, CreateQuizState> {
  final CreateQuizUsecase _createQuiz;
  final CreateSessionUsecase _createSession;
  final IQuizRepository _quizRepository;

  CreateQuizBloc(
    this._createQuiz,
    this._createSession,
    this._quizRepository, {
    bool inCourseContext = false,
    CreateQuizState? initialState,
  }) : super(
          initialState ??
              CreateQuizState(
                isInCourseContext: inCourseContext,
                quizType: inCourseContext
                    ? QuizCreationMode.test
                    : QuizCreationMode.template,
              ),
        ) {
    on<UpdateTitleEvent>((e, emit) => emit(state.copyWith(title: e.title)));
    on<UpdateDescriptionEvent>(
        (e, emit) => emit(state.copyWith(description: e.description)));
    on<UpdateTotalTimeLimitEvent>((e, emit) => emit(
          e.seconds == null
              ? state.copyWith(clearTotalTimeLimit: true)
              : state.copyWith(totalTimeLimitSec: e.seconds),
        ));
    on<UpdateQuestionTimeLimitEvent>((e, emit) => emit(
          e.seconds == null
              ? state.copyWith(clearQuestionTimeLimit: true)
              : state.copyWith(questionTimeLimitSec: e.seconds),
        ));
    on<UpdateShuffleQuestionsEvent>(
        (e, emit) => emit(state.copyWith(shuffleQuestions: e.shuffle)));
    on<UpdateStartedAtEvent>((e, emit) => emit(
          e.dateTime == null
              ? state.copyWith(clearStartedAt: true)
              : state.copyWith(startedAt: e.dateTime),
        ));
    on<UpdateFinishedAtEvent>((e, emit) => emit(
          e.dateTime == null
              ? state.copyWith(clearFinishedAt: true)
              : state.copyWith(finishedAt: e.dateTime),
        ));
    on<SetQuizTypeEvent>(
        (e, emit) => emit(state.copyWith(quizType: e.quizType)));
    on<AddQuestionEvent>((e, emit) =>
        emit(state.copyWith(questions: [...state.questions, e.question])));
    on<RemoveQuestionEvent>((e, emit) {
      final updated = List<Map<String, dynamic>>.from(state.questions)
        ..removeAt(e.index);
      emit(state.copyWith(questions: updated));
    });
    on<ReplaceQuestionEvent>((e, emit) {
      final updated = List<Map<String, dynamic>>.from(state.questions);
      updated[e.index] = e.question;
      emit(state.copyWith(questions: updated));
    });
    on<SubmitQuizEvent>(_onSubmit);
    on<ResetCreateQuizEvent>((_, emit) => emit(const CreateQuizState()));
    on<GenerateQuizQuestionsWithAiEvent>(_onGenerateQuizQuestionsWithAi);
  }

  Future<void> _onGenerateQuizQuestionsWithAi(
    GenerateQuizQuestionsWithAiEvent event,
    Emitter<CreateQuizState> emit,
  ) async {
    emit(state.copyWith(isAiGenerating: true, clearError: true));
    try {
      var quizId = state.existingQuizTemplateId;
      if (quizId == null) {
        final mode = switch (state.quizType) {
          QuizCreationMode.test => 'test',
          QuizCreationMode.live => 'live',
          QuizCreationMode.template => null,
        };
        final title =
            state.title.trim().isEmpty ? 'Новый квиз' : state.title.trim();
        quizId = await _quizRepository.createQuiz(
          title: title,
          description: state.description.isEmpty ? null : state.description,
          mode: mode,
          totalTimeLimitSec: state.totalTimeLimitSec,
          questionTimeLimitSec: state.questionTimeLimitSec,
          shuffleQuestions: state.shuffleQuestions,
          startedAt: state.startedAt,
          finishedAt: state.finishedAt,
          questions: const [],
          courseId: state.isInCourseContext ? event.courseId : null,
        );
        emit(state.copyWith(
          existingQuizTemplateId: quizId,
          isAiGenerating: true,
        ));
      }
      await _quizRepository.generateQuizQuestions(quizId, event.sourceText);
      emit(state.copyWith(
        isAiGenerating: false,
        aiGenerateAckVersion: state.aiGenerateAckVersion + 1,
      ));
    } catch (e) {
      emit(state.copyWith(
        isAiGenerating: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSubmit(
    SubmitQuizEvent event,
    Emitter<CreateQuizState> emit,
  ) async {
    final required = event.saveOnly ? state.canSave : state.canPublish;
    if (!required) return;
    emit(state.copyWith(isSubmitting: true, clearError: true));
    try {
      final mode = switch (state.quizType) {
        QuizCreationMode.test => 'test',
        QuizCreationMode.live => 'live',
        QuizCreationMode.template => null,
      };
      final existingId = state.existingQuizTemplateId;

      if (existingId != null) {
        await _quizRepository.updateQuiz(
          existingId,
          title: state.title,
          description: state.description.isEmpty ? null : state.description,
          defaultSettings: {
            if (mode != null) 'mode': mode,
            if (state.totalTimeLimitSec != null)
              'total_time_limit_sec': state.totalTimeLimitSec,
            if (state.questionTimeLimitSec != null)
              'question_time_limit_sec': state.questionTimeLimitSec,
            'shuffle_questions': state.shuffleQuestions,
            if (state.startedAt != null)
              'started_at': state.startedAt!.toUtc().toIso8601String(),
            if (state.finishedAt != null)
              'finished_at': state.finishedAt!.toUtc().toIso8601String(),
          },
        );
        for (final qid in state.originalQuestionIds) {
          await _quizRepository.removeQuestion(existingId, qid);
        }
        for (final raw in state.questions) {
          final payload = Map<String, dynamic>.from(raw);
          payload.remove('_existingQuestionId');
          await _quizRepository.addQuestion(existingId, payload);
        }
        String? liveSessionId;
        if (!event.saveOnly) {
          final sessionType = state.quizType == QuizCreationMode.live
              ? SessionType.live
              : SessionType.test;
          final sid = await _createSession(
            quizTemplateId: existingId,
            moduleId: event.moduleId!,
            sessionType: sessionType,
            totalTimeLimitSec: state.totalTimeLimitSec,
            questionTimeLimitSec: state.questionTimeLimitSec,
            shuffleQuestions: state.shuffleQuestions,
            startedAt: state.startedAt,
            finishedAt: state.finishedAt,
          );
          if (sessionType == SessionType.live) liveSessionId = sid;
        }
        emit(state.copyWith(
          isSubmitting: false,
          success: true,
          submittedModuleId: event.moduleId,
          liveSessionId: liveSessionId,
        ));
        return;
      } else if (!state.isInCourseContext || event.saveOnly) {
        await _createQuiz(
          title: state.title,
          description: state.description.isEmpty ? null : state.description,
          mode: mode,
          totalTimeLimitSec: state.totalTimeLimitSec,
          questionTimeLimitSec: state.questionTimeLimitSec,
          shuffleQuestions: state.shuffleQuestions,
          startedAt: state.startedAt,
          finishedAt: state.finishedAt,
          questions: state.questions,
          courseId: event.courseId,
        );
      } else {

        String? liveSessionId;
        if (state.quizType == QuizCreationMode.test && event.courseId != null) {

          await _quizRepository.createTestSessionInline(
            title: state.title,
            description: state.description.isEmpty ? null : state.description,
            courseId: event.courseId!,
            moduleId: event.moduleId!,
            questions: state.questions,
            totalTimeLimitSec: state.totalTimeLimitSec,
            shuffleQuestions: state.shuffleQuestions,
            startedAt: state.startedAt,
            finishedAt: state.finishedAt,
          );
        } else {

          liveSessionId = await _quizRepository.createLiveSessionInline(
            title: state.title,
            description: state.description.isEmpty ? null : state.description,
            courseId: event.courseId!,
            moduleId: event.moduleId!,
            questions: state.questions,
            questionTimeLimitSec: state.questionTimeLimitSec,
          );
        }
        emit(state.copyWith(
          isSubmitting: false,
          success: true,
          submittedModuleId: event.moduleId,
          liveSessionId: liveSessionId,
        ));
        return;
      }

      emit(state.copyWith(
        isSubmitting: false,
        success: true,
        submittedModuleId: event.moduleId,
      ));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
