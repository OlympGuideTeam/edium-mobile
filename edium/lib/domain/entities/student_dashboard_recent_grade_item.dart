part of 'student_dashboard.dart';

class RecentGradeItem {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final String attemptId;
  final double? score;
  final String status;
  final DateTime? finishedAt;

  const RecentGradeItem({
    required this.sessionId,
    required this.quizTemplateId,
    required this.quizTitle,
    required this.attemptId,
    this.score,
    required this.status,
    this.finishedAt,
  });
}

