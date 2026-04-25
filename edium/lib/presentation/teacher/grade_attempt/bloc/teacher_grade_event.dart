import 'package:equatable/equatable.dart';

abstract class TeacherGradeEvent extends Equatable {
  const TeacherGradeEvent();
  @override
  List<Object?> get props => [];
}

class LoadTeacherGradeEvent extends TeacherGradeEvent {
  final String attemptId;
  const LoadTeacherGradeEvent(this.attemptId);
  @override
  List<Object?> get props => [attemptId];
}

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

class SubmitGradesEvent extends TeacherGradeEvent {
  final String attemptId;
  final List<SubmissionGrade> grades;

  const SubmitGradesEvent({required this.attemptId, required this.grades});

  @override
  List<Object?> get props => [attemptId, grades];
}
