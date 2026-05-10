part of 'live_session.dart';

class LiveLobbyParticipant {
  final String attemptId;
  final String? userId;
  final String name;

  const LiveLobbyParticipant({
    required this.attemptId,
    this.userId,
    required this.name,
  });

  factory LiveLobbyParticipant.fromJson(Map<String, dynamic> json) =>
      LiveLobbyParticipant(
        attemptId: json['attempt_id'] as String,
        userId: json['user_id'] as String?,
        name: json['name'] as String? ?? '',
      );

  @override
  bool operator ==(Object other) =>
      other is LiveLobbyParticipant && other.attemptId == attemptId;

  @override
  int get hashCode => attemptId.hashCode;
}

