part of 'create_quiz_event.dart';

class GenerateQuizQuestionsWithAiEvent extends CreateQuizEvent {
  final String sourceText;

  final String? courseId;

  const GenerateQuizQuestionsWithAiEvent(this.sourceText, {this.courseId});

  @override
  List<Object?> get props => [sourceText, courseId];
}

