import 'package:equatable/equatable.dart';

part 'student_quiz_event_load_student_quizzes_event.dart';
part 'student_quiz_event_student_search_changed_event.dart';


abstract class StudentQuizEvent extends Equatable {
  const StudentQuizEvent();
  @override
  List<Object?> get props => [];
}

