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
  const SubmitQuizEvent();
}

class ReplaceQuestionEvent extends CreateQuizEvent {
  final int index;
  final Map<String, dynamic> question;
  const ReplaceQuestionEvent(this.index, this.question);
  @override
  List<Object?> get props => [index, question];
}

class ResetCreateQuizEvent extends CreateQuizEvent {
  const ResetCreateQuizEvent();
}
