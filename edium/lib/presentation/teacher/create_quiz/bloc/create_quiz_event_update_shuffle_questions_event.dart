part of 'create_quiz_event.dart';

class UpdateShuffleQuestionsEvent extends CreateQuizEvent {
  final bool shuffle;
  const UpdateShuffleQuestionsEvent(this.shuffle);
  @override
  List<Object?> get props => [shuffle];
}

