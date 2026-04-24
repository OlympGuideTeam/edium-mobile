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

class TeacherGradeLoaded extends TeacherGradeState {
  final AttemptReview review;
  final bool isSaving;
  final String? saveError;

  const TeacherGradeLoaded({
    required this.review,
    this.isSaving = false,
    this.saveError,
  });

  TeacherGradeLoaded copyWith({
    AttemptReview? review,
    bool? isSaving,
    String? saveError,
  }) =>
      TeacherGradeLoaded(
        review: review ?? this.review,
        isSaving: isSaving ?? this.isSaving,
        saveError: saveError,
      );

  @override
  List<Object?> get props => [review, isSaving, saveError];
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
