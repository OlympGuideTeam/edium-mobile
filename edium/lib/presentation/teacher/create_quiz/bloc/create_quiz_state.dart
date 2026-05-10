import 'package:equatable/equatable.dart';

enum QuizCreationMode { template, test, live }

class CreateQuizState extends Equatable {
  final String title;
  final String description;
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool shuffleQuestions;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final List<Map<String, dynamic>> questions;
  final bool isSubmitting;
  final String? error;
  final bool success;
  final QuizCreationMode quizType;
  final bool isInCourseContext;

  final String? existingQuizTemplateId;

  final List<String> originalQuestionIds;


  final String? submittedModuleId;

  final String? liveSessionId;


  final bool isAiGenerating;

  final int aiGenerateAckVersion;

  const CreateQuizState({
    this.title = '',
    this.description = '',
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions = false,
    this.startedAt,
    this.finishedAt,
    this.questions = const [],
    this.isSubmitting = false,
    this.error,
    this.success = false,
    this.quizType = QuizCreationMode.template,
    this.isInCourseContext = false,
    this.existingQuizTemplateId,
    this.originalQuestionIds = const [],
    this.submittedModuleId,
    this.liveSessionId,
    this.isAiGenerating = false,
    this.aiGenerateAckVersion = 0,
  });

  bool get canSave => title.isNotEmpty;
  bool get canPublish => title.isNotEmpty && questions.isNotEmpty;

  CreateQuizState copyWith({
    String? title,
    String? description,
    int? totalTimeLimitSec,
    bool clearTotalTimeLimit = false,
    int? questionTimeLimitSec,
    bool clearQuestionTimeLimit = false,
    bool? shuffleQuestions,
    DateTime? startedAt,
    bool clearStartedAt = false,
    DateTime? finishedAt,
    bool clearFinishedAt = false,
    List<Map<String, dynamic>>? questions,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool? success,
    QuizCreationMode? quizType,
    bool? isInCourseContext,
    String? existingQuizTemplateId,
    bool clearExistingQuizTemplateId = false,
    List<String>? originalQuestionIds,
    String? submittedModuleId,
    bool clearSubmittedModuleId = false,
    String? liveSessionId,
    bool? isAiGenerating,
    int? aiGenerateAckVersion,
  }) {
    return CreateQuizState(
      title: title ?? this.title,
      description: description ?? this.description,
      totalTimeLimitSec:
          clearTotalTimeLimit ? null : (totalTimeLimitSec ?? this.totalTimeLimitSec),
      questionTimeLimitSec:
          clearQuestionTimeLimit ? null : (questionTimeLimitSec ?? this.questionTimeLimitSec),
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      finishedAt: clearFinishedAt ? null : (finishedAt ?? this.finishedAt),
      questions: questions ?? this.questions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
      quizType: quizType ?? this.quizType,
      isInCourseContext: isInCourseContext ?? this.isInCourseContext,
      existingQuizTemplateId: clearExistingQuizTemplateId
          ? null
          : (existingQuizTemplateId ?? this.existingQuizTemplateId),
      originalQuestionIds: originalQuestionIds ?? this.originalQuestionIds,
      submittedModuleId: clearSubmittedModuleId
          ? null
          : (submittedModuleId ?? this.submittedModuleId),
      liveSessionId: liveSessionId ?? this.liveSessionId,
      isAiGenerating: isAiGenerating ?? this.isAiGenerating,
      aiGenerateAckVersion:
          aiGenerateAckVersion ?? this.aiGenerateAckVersion,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        totalTimeLimitSec,
        questionTimeLimitSec,
        shuffleQuestions,
        startedAt,
        finishedAt,
        questions,
        isSubmitting,
        error,
        success,
        quizType,
        isInCourseContext,
        existingQuizTemplateId,
        originalQuestionIds,
        submittedModuleId,
        liveSessionId,
        isAiGenerating,
        aiGenerateAckVersion,
      ];
}
