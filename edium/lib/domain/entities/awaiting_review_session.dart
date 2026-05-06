class AwaitingReviewSession {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final int gradingCount;
  final int gradedCount;
  final int completedCount;

  const AwaitingReviewSession({
    required this.sessionId,
    required this.quizTemplateId,
    required this.quizTitle,
    required this.gradingCount,
    required this.gradedCount,
    required this.completedCount,
  });

  int get pendingTeacherReview => gradedCount;
}
