part of 'student_dashboard_model.dart';

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

