import 'package:edium/domain/entities/live_ws_event.dart';

sealed class LiveTeacherEvent {}

class LiveTeacherLoad extends LiveTeacherEvent {
  final String sessionId;
  final String quizTitle;
  final int questionCount;
  /// Модуль курса (Caesar) — для GET `/caesar/v1/modules/{id}/roster`; вне курса null.
  final String? moduleId;

  LiveTeacherLoad({
    required this.sessionId,
    required this.quizTitle,
    required this.questionCount,
    this.moduleId,
  });
}

class LiveTeacherWsEvent extends LiveTeacherEvent {
  final LiveWsEvent event;
  LiveTeacherWsEvent(this.event);
}

class LiveTeacherStartLobby extends LiveTeacherEvent {}

class LiveTeacherStartQuiz extends LiveTeacherEvent {}

class LiveTeacherNextQuestion extends LiveTeacherEvent {}

class LiveTeacherKickParticipant extends LiveTeacherEvent {
  final String attemptId;
  LiveTeacherKickParticipant(this.attemptId);
}

class LiveTeacherLoadResults extends LiveTeacherEvent {}

class LiveTeacherDispose extends LiveTeacherEvent {}
