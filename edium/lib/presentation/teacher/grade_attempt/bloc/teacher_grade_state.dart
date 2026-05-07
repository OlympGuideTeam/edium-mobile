import 'package:edium/domain/entities/attempt_review.dart';
import 'package:equatable/equatable.dart';

abstract class TeacherGradeState extends Equatable {
  const TeacherGradeState();
  @override
  List<Object?> get props => [];
}

class TeacherGradeInitial extends TeacherGradeState {
  const TeacherGradeInitial();
}

class TeacherGradeLoading extends TeacherGradeState {
  const TeacherGradeLoading();
}

/// submissionId → (score, feedback)
typedef LocalGrades = Map<String, ({double score, String? feedback})>;

class TeacherGradeLoaded extends TeacherGradeState {
  final AttemptReview review;
  final bool isSaving;
  final String? saveError;
  final LocalGrades localGrades;

  const TeacherGradeLoaded({
    required this.review,
    this.isSaving = false,
    this.saveError,
    this.localGrades = const {},
  });

  TeacherGradeLoaded copyWith({
    AttemptReview? review,
    bool? isSaving,
    String? saveError,
    LocalGrades? localGrades,
  }) =>
      TeacherGradeLoaded(
        review: review ?? this.review,
        isSaving: isSaving ?? this.isSaving,
        saveError: saveError,
        localGrades: localGrades ?? this.localGrades,
      );

  @override
  List<Object?> get props => [review, isSaving, saveError, localGrades];
}

class TeacherGradeError extends TeacherGradeState {
  final String message;
  const TeacherGradeError(this.message);
  @override
  List<Object?> get props => [message];
}

class TeacherGradeCompleted extends TeacherGradeState {
  const TeacherGradeCompleted();
}
