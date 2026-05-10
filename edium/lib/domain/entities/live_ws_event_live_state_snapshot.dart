part of 'live_ws_event.dart';

class LiveStateSnapshot extends LiveWsEvent {
  final LivePhase phase;
  final int? questionIndex;
  final int questionTotal;
  final LiveQuestion? currentQuestion;
  final DateTime? questionStartedAt;
  final DateTime? questionDeadlineAt;
  final int? timeLimitSec;
  final Map<String, dynamic>? myAnswer;
  final List<LiveLobbyParticipant> lobbyParticipants;
  final LiveLockedData? lastQuestionLocked;

  LiveStateSnapshot({
    required this.phase,
    this.questionIndex,
    required this.questionTotal,
    this.currentQuestion,
    this.questionStartedAt,
    this.questionDeadlineAt,
    this.timeLimitSec,
    this.myAnswer,
    required this.lobbyParticipants,
    this.lastQuestionLocked,
  });

  factory LiveStateSnapshot.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final qIdxRaw =
        (data['question_idx'] as num?) ?? (data['question_index'] as num?);
    final qIdx = _liveQuestionIndexOneBasedFromPayload(qIdxRaw);
    final deadlineRaw = data['question_deadline_at'] as String? ??
        data['deadline_at'] as String?;
    return LiveStateSnapshot(
      phase: livePhaseFromString(data['phase'] as String? ?? 'pending'),
      questionIndex: qIdx,
      questionTotal: (data['question_total'] as num?)?.toInt() ?? 0,
      currentQuestion: data['current_question'] != null
          ? LiveQuestion.fromJson(
              data['current_question'] as Map<String, dynamic>)
          : null,
      questionStartedAt: data['question_started_at'] != null
          ? DateTime.tryParse(data['question_started_at'] as String)
          : null,
      questionDeadlineAt: deadlineRaw != null
          ? DateTime.tryParse(deadlineRaw)
          : null,
      timeLimitSec: (data['time_limit_sec'] as num?)?.toInt(),
      myAnswer: data['my_answer'] as Map<String, dynamic>?,
      lobbyParticipants: (data['participants'] as List<dynamic>? ?? [])
          .map(
              (e) => LiveLobbyParticipant.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastQuestionLocked: data['last_question_locked'] != null
          ? LiveLockedData.fromJson(
              data['last_question_locked'] as Map<String, dynamic>)
          : null,
    );
  }
}

