part of 'live_ws_event.dart';

class LiveParticipantKicked extends LiveWsEvent {
  final String attemptId;
  LiveParticipantKicked({required this.attemptId});
  factory LiveParticipantKicked.fromJson(Map<String, dynamic> data) =>
      LiveParticipantKicked(attemptId: data['attempt_id'] as String);
}

