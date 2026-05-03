import 'package:edium/domain/entities/live_ws_event.dart';

sealed class LiveStudentEvent {}

class LiveStudentStart extends LiveStudentEvent {
  final String sessionId;
  final String attemptId;
  final String wsToken;
  final String quizTitle;
  final int questionCount;
  /// Модуль курса — GET `/caesar/v1/modules/{id}/roster` для имён в лобби.
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

class LiveStudentWsEvent extends LiveStudentEvent {
  final LiveWsEvent event;
  LiveStudentWsEvent(this.event);
}

class LiveStudentSubmitAnswer extends LiveStudentEvent {
  final String questionId;
  final Map<String, dynamic> answerData;

  LiveStudentSubmitAnswer({
    required this.questionId,
    required this.answerData,
  });
}

class LiveStudentLoadResults extends LiveStudentEvent {}

class LiveStudentDispose extends LiveStudentEvent {}
