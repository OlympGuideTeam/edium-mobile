part of 'live_session.dart';

class LiveStartResult {
  final String wsToken;
  final String joinCode;

  const LiveStartResult({required this.wsToken, required this.joinCode});

  factory LiveStartResult.fromJson(Map<String, dynamic> json) => LiveStartResult(
        wsToken: json['ws_token'] as String,
        joinCode: json['join_code'] as String,
      );
}

