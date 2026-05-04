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
  final String source; // 'course' | 'library'
  final LivePhase phase;
  final String? joinCode; // only for teacher in lobby phase
  final int questionTimeLimitSec;
  final bool isAnonymousAllowed;
  final int participantsCount;
  /// Модуль курса (Caesar) — для roster; может приходить с resolve/join meta.
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

class LiveRosterMember {
  final String userId;
  final String name;

  const LiveRosterMember({required this.userId, required this.name});

  factory LiveRosterMember.fromJson(Map<String, dynamic> json) =>
      LiveRosterMember(
        userId: json['user_id'] as String,
        name: json['name'] as String? ?? '',
      );

  /// Caesar `MemberShort` в GET `/caesar/v1/modules/{moduleId}/roster`.
  factory LiveRosterMember.fromModuleRosterMemberJson(
    Map<String, dynamic> json,
  ) {
    final userId = json['user_id'] as String? ?? json['id'] as String? ?? '';
    final name = json['name'] as String? ?? '';
    final surname = json['surname'] as String? ?? '';
    final parts = [name, surname].where((s) => s.isNotEmpty).toList();
    final display = parts.join(' ');
    return LiveRosterMember(
      userId: userId,
      name: display.isNotEmpty ? display : (name.isNotEmpty ? name : userId),
    );
  }
}

class LiveJoinResult {
  final String attemptId;
  final String wsToken;
  /// Курсовый live — Caesar модуль для roster (если бэкенд отдаёт в теле join).
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

class LiveStartResult {
  final String wsToken;
  final String joinCode;

  const LiveStartResult({required this.wsToken, required this.joinCode});

  factory LiveStartResult.fromJson(Map<String, dynamic> json) => LiveStartResult(
        wsToken: json['ws_token'] as String,
        joinCode: json['join_code'] as String,
      );
}

/// Элемент списка лайв-сессий учителя (GET /riddler/v1/sessions/live).
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
