import 'package:edium/domain/entities/attempt_review.dart';
import 'package:equatable/equatable.dart';

part 'teacher_grade_state_teacher_grade_initial.dart';
part 'teacher_grade_state_teacher_grade_loading.dart';
part 'teacher_grade_state_teacher_grade_loaded.dart';
part 'teacher_grade_state_teacher_grade_error.dart';
part 'teacher_grade_state_teacher_grade_completed.dart';


abstract class TeacherGradeState extends Equatable {
  const TeacherGradeState();
  @override
  List<Object?> get props => [];
}

