import 'package:equatable/equatable.dart';

part 'teacher_grade_event_load_teacher_grade_event.dart';
part 'teacher_grade_event_submission_grade.dart';
part 'teacher_grade_event_submit_grades_event.dart';
part 'teacher_grade_event_update_local_grade_event.dart';
part 'teacher_grade_event_complete_grading_event.dart';


abstract class TeacherGradeEvent extends Equatable {
  const TeacherGradeEvent();
  @override
  List<Object?> get props => [];
}

