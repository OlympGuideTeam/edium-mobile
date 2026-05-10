part of 'teacher_grade_event.dart';

class SubmissionGrade extends Equatable {
  final String submissionId;
  final double score;
  final String? feedback;

  const SubmissionGrade({
    required this.submissionId,
    required this.score,
    this.feedback,
  });

  @override
  List<Object?> get props => [submissionId, score, feedback];
}

