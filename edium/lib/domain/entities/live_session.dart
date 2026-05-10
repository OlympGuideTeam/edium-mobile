
part 'live_session_live_lobby_participant.dart';
part 'live_session_live_roster_member.dart';
part 'live_session_live_join_result.dart';
part 'live_session_live_start_result.dart';
part 'live_session_live_library_session.dart';

enum LivePhase { pending, lobby, questionActive, questionLocked, completed }

LivePhase livePhaseFromString(String s) => switch (s) {
      'pending' => LivePhase.pending,
      'lobby' => LivePhase.lobby,
      'question_active' => LivePhase.questionActive,
      'question_locked' => LivePhase.questionLocked,
      'completed' => LivePhase.completed,
      _ => LivePhase.pending,
    };

class LiveSessionMeta {
  final String sessionId;
  final String quizTemplateId;
  final String quizTitle;
  final int questionCount;
  final String source;
  final LivePhase phase;
  final String? joinCode;
  final int questionTimeLimitSec;
  final bool isAnonymousAllowed;
  final int participantsCount;

  final String? moduleId;

  const LiveSessionMeta({
    required this.sessionId,
    required this.quizTemplateId,
    required this.quizTitle,
    required this.questionCount,
    required this.source,
    required this.phase,
    this.joinCode,
    required this.questionTimeLimitSec,
    required this.isAnonymousAllowed,
    required this.participantsCount,
    this.moduleId,
  });

  factory LiveSessionMeta.fromJson(Map<String, dynamic> json) =>
      LiveSessionMeta(
        sessionId: json['session_id'] as String,
        quizTemplateId: json['quiz_template_id'] as String? ?? '',
        quizTitle: json['quiz_title'] as String? ?? '',
        questionCount: (json['question_count'] as num?)?.toInt() ?? 0,
        source: json['source'] as String? ?? 'library',
        phase: livePhaseFromString(json['phase'] as String? ?? 'lobby'),
        joinCode: json['join_code'] as String?,
        questionTimeLimitSec:
            (json['question_time_limit_sec'] as num?)?.toInt() ?? 30,
        isAnonymousAllowed: json['is_anonymous_allowed'] as bool? ?? false,
        participantsCount:
            (json['participants_count'] as num?)?.toInt() ?? 0,
        moduleId: json['module_id'] as String?,
      );
}

