
part 'quiz_session_quiz_session.dart';

enum SessionStatus { inProgress, completed }

class AnswerRecord {
  final String questionId;
  final dynamic answer;
  final bool? correct;
  final String? explanation;

  const AnswerRecord({
    required this.questionId,
    required this.answer,
    this.correct,
    this.explanation,
  });
}

