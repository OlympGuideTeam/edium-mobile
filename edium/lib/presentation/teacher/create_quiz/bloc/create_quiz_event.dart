import 'package:edium/domain/entities/quiz.dart';
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

class UpdateSubjectEvent extends CreateQuizEvent {
  final String subject;
  const UpdateSubjectEvent(this.subject);
  @override
  List<Object?> get props => [subject];
}

class UpdateSettingsEvent extends CreateQuizEvent {
  final QuizSettings settings;
  const UpdateSettingsEvent(this.settings);
  @override
  List<Object?> get props => [settings];
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
  const SubmitQuizEvent();
}

class ResetCreateQuizEvent extends CreateQuizEvent {
  const ResetCreateQuizEvent();
}
