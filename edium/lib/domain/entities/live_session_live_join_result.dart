part of 'live_session.dart';

class LiveJoinResult {
  final String attemptId;
  final String wsToken;

  final String? moduleId;

  const LiveJoinResult({
    required this.attemptId,
    required this.wsToken,
    this.moduleId,
  });

  factory LiveJoinResult.fromJson(Map<String, dynamic> json) => LiveJoinResult(
        attemptId: json['attempt_id'] as String,
        wsToken: json['ws_token'] as String,
        moduleId: json['module_id'] as String?,
      );
}

