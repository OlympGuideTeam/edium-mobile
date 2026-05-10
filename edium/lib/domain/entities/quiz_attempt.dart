
part 'quiz_attempt_quiz_question_for_student.dart';
part 'quiz_attempt_quiz_attempt.dart';
part 'quiz_attempt_answer_submission_result.dart';
part 'quiz_attempt_attempt_result.dart';

enum QuizQuestionType {
  singleChoice,
  multipleChoice,
  withGivenAnswer,
  withFreeAnswer,
  drag,
  connection,
}

class QuestionOptionForStudent {
  final String id;
  final String text;

  const QuestionOptionForStudent({required this.id, required this.text});
}

