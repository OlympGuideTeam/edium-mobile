part of 'live_student_event.dart';

class LiveStudentStart extends LiveStudentEvent {
  final String sessionId;
  final String attemptId;
  final String wsToken;
  final String quizTitle;
  final int questionCount;

  final String? moduleId;

  LiveStudentStart({
    required this.sessionId,
    required this.attemptId,
    required this.wsToken,
    required this.quizTitle,
    required this.questionCount,
    this.moduleId,
  });
}

