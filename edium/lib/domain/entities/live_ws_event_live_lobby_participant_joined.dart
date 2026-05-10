part of 'live_ws_event.dart';

class LiveLobbyParticipantJoined extends LiveWsEvent {
  final String attemptId;
  final String? userId;
  final String name;

  LiveLobbyParticipantJoined({
    required this.attemptId,
    this.userId,
    required this.name,
  });

  factory LiveLobbyParticipantJoined.fromJson(Map<String, dynamic> data) =>
      LiveLobbyParticipantJoined(
        attemptId: data['attempt_id'] as String,
        userId: data['user_id'] as String?,
        name: data['name'] as String? ?? '',
      );
}

