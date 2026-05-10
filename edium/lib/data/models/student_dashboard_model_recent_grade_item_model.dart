part of 'student_dashboard_model.dart';

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

