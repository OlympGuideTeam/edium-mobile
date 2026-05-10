import 'package:edium/domain/entities/quiz_attempt.dart'
    show AttemptStatus, QuizQuestionType;

part 'attempt_review_answer_review.dart';
part 'attempt_review_attempt_review.dart';


class TeacherAnswerOption {
  final String id;
  final String text;
  final bool isCorrect;

  const TeacherAnswerOption({
    required this.id,
    required this.text,
    required this.isCorrect,
  });
}

