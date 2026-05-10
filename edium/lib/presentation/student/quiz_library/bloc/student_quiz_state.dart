import 'package:edium/domain/entities/library_quiz.dart';
import 'package:equatable/equatable.dart';

part 'student_quiz_state_student_quiz_initial.dart';
part 'student_quiz_state_student_quiz_loading.dart';
part 'student_quiz_state_student_quiz_loaded.dart';
part 'student_quiz_state_student_quiz_error.dart';


abstract class StudentQuizState extends Equatable {
  const StudentQuizState();
  @override
  List<Object?> get props => [];
}

