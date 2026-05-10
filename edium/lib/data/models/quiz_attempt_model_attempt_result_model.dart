part of 'quiz_attempt_model.dart';

class AttemptResultModel {
  final String attemptId;
  final String status;
  final double? score;
  final String startedAt;
  final String? finishedAt;
  final List<AnswerSubmissionResultModel> answers;

  const AttemptResultModel({
    required this.attemptId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });

  factory AttemptResultModel.fromJson(Map<String, dynamic> json) {
    return AttemptResultModel(
      attemptId: json['attempt_id'] as String,
      status: json['status'] as String? ?? 'completed',
      score: (json['score'] as num?)?.toDouble(),
      startedAt: json['started_at'] as String,
      finishedAt: json['finished_at'] as String?,
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((e) => AnswerSubmissionResultModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
    );
  }

  AttemptResult toEntity() {
    AttemptStatus st;
    switch (status) {
      case 'grading':
        st = AttemptStatus.grading;
        break;
      case 'graded':
        st = AttemptStatus.graded;
        break;
      case 'completed':
        st = AttemptStatus.completed;
        break;
      case 'published':
        st = AttemptStatus.published;
        break;
      default:
        st = AttemptStatus.inProgress;
    }
    return AttemptResult(
      attemptId: attemptId,
      status: st,
      score: score,
      startedAt: DateTime.parse(startedAt),
      finishedAt: finishedAt != null ? DateTime.parse(finishedAt!) : null,
      answers: answers.map((e) => e.toEntity()).toList(),
    );
  }
}

