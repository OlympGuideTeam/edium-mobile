part of 'teacher_grade_event.dart';

class UpdateLocalGradeEvent extends TeacherGradeEvent {
  final String submissionId;
  final double score;
  final String? feedback;

  const UpdateLocalGradeEvent({
    required this.submissionId,
    required this.score,
    this.feedback,
  });

  @override
  List<Object?> get props => [submissionId, score, feedback];
}

