class StudentDashboard {
  final List<RecentGradeItem> recentGrades;
  final List<ActiveTestItem> activeTests;

  const StudentDashboard({
    required this.recentGrades,
    required this.activeTests,
  });
}

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
