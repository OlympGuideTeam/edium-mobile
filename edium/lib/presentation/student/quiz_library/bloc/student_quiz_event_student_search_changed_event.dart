part of 'student_quiz_event.dart';

class StudentSearchChangedEvent extends StudentQuizEvent {
  final String query;
  const StudentSearchChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}

