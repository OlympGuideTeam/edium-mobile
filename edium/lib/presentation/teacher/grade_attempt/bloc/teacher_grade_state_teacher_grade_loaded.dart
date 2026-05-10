part of 'teacher_grade_state.dart';

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

