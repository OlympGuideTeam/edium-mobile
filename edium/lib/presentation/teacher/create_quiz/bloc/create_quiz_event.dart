import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:equatable/equatable.dart';

abstract class CreateQuizEvent extends Equatable {
  const CreateQuizEvent();
  @override
  List<Object?> get props => [];
}

class UpdateTitleEvent extends CreateQuizEvent {
  final String title;
  const UpdateTitleEvent(this.title);
  @override
  List<Object?> get props => [title];
}

class UpdateDescriptionEvent extends CreateQuizEvent {
  final String description;
  const UpdateDescriptionEvent(this.description);
  @override
  List<Object?> get props => [description];
}

class UpdateTotalTimeLimitEvent extends CreateQuizEvent {
  final int? seconds;
  const UpdateTotalTimeLimitEvent(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class UpdateQuestionTimeLimitEvent extends CreateQuizEvent {
  final int? seconds;
  const UpdateQuestionTimeLimitEvent(this.seconds);
  @override
  List<Object?> get props => [seconds];
}

class UpdateShuffleQuestionsEvent extends CreateQuizEvent {
  final bool shuffle;
  const UpdateShuffleQuestionsEvent(this.shuffle);
  @override
  List<Object?> get props => [shuffle];
}

class AddQuestionEvent extends CreateQuizEvent {
  final Map<String, dynamic> question;
  const AddQuestionEvent(this.question);
  @override
  List<Object?> get props => [question];
}

class RemoveQuestionEvent extends CreateQuizEvent {
  final int index;
  const RemoveQuestionEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class SubmitQuizEvent extends CreateQuizEvent {
  /// When true, creates template only (no session), even in course context.
  final bool saveOnly;
  /// Course id for attach_to_course (saveOnly path).
  final String? courseId;
  /// Module id for session creation (Начать path).
  final String? moduleId;
  const SubmitQuizEvent({this.saveOnly = false, this.courseId, this.moduleId});
  @override
  List<Object?> get props => [saveOnly, courseId, moduleId];
}

class ReplaceQuestionEvent extends CreateQuizEvent {
  final int index;
  final Map<String, dynamic> question;
  const ReplaceQuestionEvent(this.index, this.question);
  @override
  List<Object?> get props => [index, question];
}

class SetQuizTypeEvent extends CreateQuizEvent {
  final QuizCreationMode quizType;
  const SetQuizTypeEvent(this.quizType);
  @override
  List<Object?> get props => [quizType];
}

class UpdateStartedAtEvent extends CreateQuizEvent {
  final DateTime? dateTime;
  const UpdateStartedAtEvent(this.dateTime);
  @override
  List<Object?> get props => [dateTime];
}

class UpdateFinishedAtEvent extends CreateQuizEvent {
  final DateTime? dateTime;
  const UpdateFinishedAtEvent(this.dateTime);
  @override
  List<Object?> get props => [dateTime];
}

class ResetCreateQuizEvent extends CreateQuizEvent {
  const ResetCreateQuizEvent();
}

/// Генерация вопросов по тексту через Riddler (`/quizzes/{id}/generate`).
class GenerateQuizQuestionsWithAiEvent extends CreateQuizEvent {
  final String sourceText;
  /// Для привязки черновика к курсу при первом создании шаблона.
  final String? courseId;

  const GenerateQuizQuestionsWithAiEvent(this.sourceText, {this.courseId});

  @override
  List<Object?> get props => [sourceText, courseId];
}
