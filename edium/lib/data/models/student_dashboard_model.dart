import 'package:edium/domain/entities/student_dashboard.dart';

class StudentDashboardModel {
  final List<RecentGradeItemModel> recentGrades;
  final List<ActiveTestItemModel> activeTests;

  const StudentDashboardModel({
    required this.recentGrades,
    required this.activeTests,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    final grades = (json['recent_grades'] as List<dynamic>? ?? [])
        .map((e) => RecentGradeItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final tests = (json['active_tests'] as List<dynamic>? ?? [])
        .map((e) => ActiveTestItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return StudentDashboardModel(recentGrades: grades, activeTests: tests);
  }

  StudentDashboard toEntity() => StudentDashboard(
        recentGrades: recentGrades.map((m) => m.toEntity()).toList(),
        activeTests: activeTests.map((m) => m.toEntity()).toList(),
      );
}

class RecentGradeItemModel {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final String attemptId;
  final double? score;
  final String status;
  final DateTime? finishedAt;

  const RecentGradeItemModel({
    required this.sessionId,
    required this.quizTemplateId,
    required this.quizTitle,
    required this.attemptId,
    this.score,
    required this.status,
    this.finishedAt,
  });

  factory RecentGradeItemModel.fromJson(Map<String, dynamic> json) {
    return RecentGradeItemModel(
      sessionId: json['session_id'] as String,
      quizTemplateId: json['quiz_template_id'] as String,
      quizTitle: json['quiz_title'] as String,
      attemptId: json['attempt_id'] as String,
      score: (json['score'] as num?)?.toDouble(),
      status: json['status'] as String,
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'] as String)
          : null,
    );
  }

  RecentGradeItem toEntity() => RecentGradeItem(
        sessionId: sessionId,
        quizTemplateId: quizTemplateId,
        quizTitle: quizTitle,
        attemptId: attemptId,
        score: score,
        status: status,
        finishedAt: finishedAt,
      );
}

class ActiveTestItemModel {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final int? totalTimeLimitSec;
  final DateTime? sessionStartedAt;
  final DateTime? sessionFinishedAt;
  final String? attemptId;
  final String? attemptStatus;

  const ActiveTestItemModel({
    required this.sessionId,
    required this.quizTemplateId,
    required this.quizTitle,
    this.totalTimeLimitSec,
    this.sessionStartedAt,
    this.sessionFinishedAt,
    this.attemptId,
    this.attemptStatus,
  });

  factory ActiveTestItemModel.fromJson(Map<String, dynamic> json) {
    return ActiveTestItemModel(
      sessionId: json['session_id'] as String,
      quizTemplateId: json['quiz_template_id'] as String,
      quizTitle: json['quiz_title'] as String,
      totalTimeLimitSec: (json['total_time_limit_sec'] as num?)?.toInt(),
      sessionStartedAt: json['session_started_at'] != null
          ? DateTime.parse(json['session_started_at'] as String)
          : null,
      sessionFinishedAt: json['session_finished_at'] != null
          ? DateTime.parse(json['session_finished_at'] as String)
          : null,
      attemptId: json['attempt_id'] as String?,
      attemptStatus: json['attempt_status'] as String?,
    );
  }

  ActiveTestItem toEntity() => ActiveTestItem(
        sessionId: sessionId,
        quizTemplateId: quizTemplateId,
        quizTitle: quizTitle,
        totalTimeLimitSec: totalTimeLimitSec,
        sessionStartedAt: sessionStartedAt,
        sessionFinishedAt: sessionFinishedAt,
        attemptId: attemptId,
        attemptStatus: attemptStatus,
      );
}
