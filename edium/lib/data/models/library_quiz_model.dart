import 'package:edium/domain/entities/library_quiz.dart';

part 'library_quiz_model_quiz_default_settings_model.dart';
part 'library_quiz_model_library_quiz_model.dart';


class QuizAttemptSummaryModel {
  final String id;
  final String sessionId;
  final String sessionType;
  final String status;
  final double? score;
  final String startedAt;
  final String? finishedAt;

  const QuizAttemptSummaryModel({
    required this.id,
    required this.sessionId,
    required this.sessionType,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
  });

  factory QuizAttemptSummaryModel.fromJson(Map<String, dynamic> json) {
    return QuizAttemptSummaryModel(
      id: json['id'] as String,
      sessionId: json['session_id'] as String,
      sessionType: json['session_type'] as String? ?? 'test',
      status: json['status'] as String,
      score: (json['score'] as num?)?.toDouble(),
      startedAt: json['started_at'] as String,
      finishedAt: json['finished_at'] as String?,
    );
  }

  QuizAttemptSummary toEntity() => QuizAttemptSummary(
        id: id,
        sessionId: sessionId,
        sessionType: sessionType,
        status: status,
        score: score,
        startedAt: DateTime.parse(startedAt),
        finishedAt: finishedAt != null ? DateTime.parse(finishedAt!) : null,
      );
}

