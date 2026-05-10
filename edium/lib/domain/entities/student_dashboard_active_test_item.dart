part of 'student_dashboard.dart';

class ActiveTestItem {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final int? totalTimeLimitSec;
  final DateTime? sessionStartedAt;
  final DateTime? sessionFinishedAt;
  final String? attemptId;
  final String? attemptStatus;

  const ActiveTestItem({
    required this.sessionId,
    required this.quizTemplateId,
    required this.quizTitle,
    this.totalTimeLimitSec,
    this.sessionStartedAt,
    this.sessionFinishedAt,
    this.attemptId,
    this.attemptStatus,
  });
}

