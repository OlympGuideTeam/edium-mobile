import 'package:edium/domain/entities/quiz.dart';
import 'package:equatable/equatable.dart';

class CreateQuizState extends Equatable {
  final String title;
  final String subject;
  final QuizSettings settings;
  final List<Map<String, dynamic>> questions;
  final bool isSubmitting;
  final String? error;
  final bool success;

  const CreateQuizState({
    this.title = '',
    this.subject = '',
    this.settings = const QuizSettings(),
    this.questions = const [],
    this.isSubmitting = false,
    this.error,
    this.success = false,
  });

  bool get canSubmit =>
      title.isNotEmpty &&
      subject.isNotEmpty &&
      questions.isNotEmpty &&
      (settings.timeLimitMinutes != null || settings.deadline != null);

  bool get needsTimeOrDeadline =>
      settings.timeLimitMinutes == null && settings.deadline == null;

  CreateQuizState copyWith({
    String? title,
    String? subject,
    QuizSettings? settings,
    List<Map<String, dynamic>>? questions,
    bool? isSubmitting,
    String? error,
    bool? success,
  }) {
    return CreateQuizState(
      title: title ?? this.title,
      subject: subject ?? this.subject,
      settings: settings ?? this.settings,
      questions: questions ?? this.questions,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      success: success ?? this.success,
    );
  }

  @override
  List<Object?> get props =>
      [title, subject, settings, questions, isSubmitting, error, success];
}
