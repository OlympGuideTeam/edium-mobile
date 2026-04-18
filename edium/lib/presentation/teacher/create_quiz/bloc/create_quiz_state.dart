import 'package:equatable/equatable.dart';

class CreateQuizState extends Equatable {
  final String title;
  final String description;
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool shuffleQuestions;
  final List<Map<String, dynamic>> questions;
  final bool isSubmitting;
  final String? error;
  final bool success;

  const CreateQuizState({
    this.title = '',
    this.description = '',
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions = false,
    this.questions = const [],
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  bool get canSubmit => title.isNotEmpty && questions.isNotEmpty;

  CreateQuizState copyWith({
    String? title,
    String? description,
    int? totalTimeLimitSec,
    bool clearTotalTimeLimit = false,
    int? questionTimeLimitSec,
    bool clearQuestionTimeLimit = false,
    bool? shuffleQuestions,
    List<Map<String, dynamic>>? questions,
    bool? isSubmitting,
    String? error,
    bool clearError = false,
    bool? success,
  }) {
    return CreateQuizState(
      title: title ?? this.title,
      description: description ?? this.description,
      totalTimeLimitSec: clearTotalTimeLimit ? null : (totalTimeLimitSec ?? this.totalTimeLimitSec),
      questionTimeLimitSec: clearQuestionTimeLimit ? null : (questionTimeLimitSec ?? this.questionTimeLimitSec),
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      questions: questions ?? this.questions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: clearError ? null : (error ?? this.error),
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props => [
        title,
        description,
        totalTimeLimitSec,
        questionTimeLimitSec,
        shuffleQuestions,
        questions,
        isSubmitting,
        error,
        success,
      ];
}
