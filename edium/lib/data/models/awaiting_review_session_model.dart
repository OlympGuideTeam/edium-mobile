import 'package:edium/domain/entities/awaiting_review_session.dart';

class AwaitingReviewSessionModel {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final int gradingCount;
  final int gradedCount;
  final int completedCount;

  const AwaitingReviewSessionModel({
    required this.sessionId,
    required this.quizTemplateId,
    required this.quizTitle,
    required this.gradingCount,
    required this.gradedCount,
    required this.completedCount,
  });

  factory AwaitingReviewSessionModel.fromJson(Map<String, dynamic> json) {
    return AwaitingReviewSessionModel(
      sessionId: json['session_id'] as String,
      quizTemplateId: json['quiz_template_id'] as String,
      quizTitle: json['quiz_title'] as String,
      gradingCount: (json['grading_count'] as num?)?.toInt() ?? 0,
      gradedCount: (json['graded_count'] as num?)?.toInt() ?? 0,
      completedCount: (json['completed_count'] as num?)?.toInt() ?? 0,
    );
  }

  AwaitingReviewSession toEntity() => AwaitingReviewSession(
        sessionId: sessionId,
        quizTemplateId: quizTemplateId,
        quizTitle: quizTitle,
        gradingCount: gradingCount,
        gradedCount: gradedCount,
        completedCount: completedCount,
      );
}
