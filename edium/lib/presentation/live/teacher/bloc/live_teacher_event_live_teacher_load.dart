part of 'live_teacher_event.dart';

class LiveTeacherLoad extends LiveTeacherEvent {
  final String sessionId;
  final String quizTitle;
  final int questionCount;

  final String? moduleId;

  LiveTeacherLoad({
    required this.sessionId,
    required this.quizTitle,
    required this.questionCount,
    this.moduleId,
  });
}

