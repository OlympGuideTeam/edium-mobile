part of 'live_session.dart';

class LiveLibrarySession {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final String status;
  final LivePhase phase;
  final String? joinCode;
  final int participantsCount;
  final DateTime createdAt;

  const LiveLibrarySession({
    required this.sessionId,
    required this.quizTemplateId,
    required this.quizTitle,
    required this.status,
    required this.phase,
    this.joinCode,
    required this.participantsCount,
    required this.createdAt,
  });

  factory LiveLibrarySession.fromJson(Map<String, dynamic> json) =>
      LiveLibrarySession(
        sessionId: json['session_id'] as String,
        quizTemplateId: json['quiz_template_id'] as String? ?? '',
        quizTitle: json['quiz_title'] as String? ?? '',
        status: json['status'] as String? ?? 'not_started',
        phase: livePhaseFromString(json['phase'] as String? ?? 'pending'),
        joinCode: json['join_code'] as String?,
        participantsCount: (json['participants_count'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.now(),
      );
}

