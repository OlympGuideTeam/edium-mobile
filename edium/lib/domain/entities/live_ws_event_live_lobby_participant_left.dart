part of 'live_ws_event.dart';

class LiveLobbyParticipantLeft extends LiveWsEvent {
  final String attemptId;

  LiveLobbyParticipantLeft({required this.attemptId});

  factory LiveLobbyParticipantLeft.fromJson(Map<String, dynamic> data) =>
      LiveLobbyParticipantLeft(attemptId: data['attempt_id'] as String);
}

