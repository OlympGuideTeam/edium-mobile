part of 'live_results.dart';

class LiveLeaderboardRow {
  final int position;
  final String attemptId;
  final String? userId;
  final String name;
  final double score;
  final bool isMe;

  const LiveLeaderboardRow({
    required this.position,
    required this.attemptId,
    this.userId,
    required this.name,
    required this.score,
    required this.isMe,
  });

  factory LiveLeaderboardRow.fromJson(Map<String, dynamic> json) =>
      LiveLeaderboardRow(
        position: (json['position'] as num?)?.toInt() ?? 0,
        attemptId: json['attempt_id'] as String? ?? '',
        userId: json['user_id'] as String?,
        name: json['name'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
        isMe: json['is_me'] as bool? ?? false,
      );
}

