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

class QuizSession {
  final String id;
  final String quizId;
  final String userId;
  final SessionStatus status;
  final List<AnswerRecord> answers;
  final int? score;
  final int? totalQuestions;
  final DateTime startedAt;
  final DateTime? completedAt;

  const QuizSession({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.status,
    required this.answers,
    this.score,
    this.totalQuestions,
    required this.startedAt,
    this.completedAt,
  });

  double get percentage =>
      (totalQuestions != null && totalQuestions! > 0 && score != null)
          ? score! / totalQuestions!
          : 0.0;

  QuizSession copyWith({
    String? id,
    String? quizId,
    String? userId,
    SessionStatus? status,
    List<AnswerRecord>? answers,
    int? score,
    int? totalQuestions,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return QuizSession(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      answers: answers ?? this.answers,
      score: score ?? this.score,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
