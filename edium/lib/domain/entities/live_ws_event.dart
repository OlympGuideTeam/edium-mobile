import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_session.dart';

// ─── Server → Client events ──────────────────────────────────────────────────

/// `question_idx` / `question_index` в live WS приходят 0-based; в UI — «Вопрос N», N с 1.
int? _liveQuestionIndexOneBasedFromPayload(num? raw) =>
    raw == null ? null : raw.toInt() + 1;

sealed class LiveWsEvent {}

/// Полный снапшот состояния. Сервер шлёт сразу при подключении / реконнекте.
class LiveStateSnapshot extends LiveWsEvent {
  final LivePhase phase;
  final int? questionIndex;
  final int questionTotal;
  final LiveQuestion? currentQuestion;
  final DateTime? questionStartedAt;
  final DateTime? questionDeadlineAt;
  final int? timeLimitSec;
  final Map<String, dynamic>? myAnswer; // student only
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

class LiveLockedData {
  final String questionId;
  final LiveCorrectAnswer correctAnswer;
  final LiveQuestionStats stats;
  final LiveStudentResult? myResult;
  final List<String>? wordCloud;

  const LiveLockedData({
    required this.questionId,
    required this.correctAnswer,
    required this.stats,
    this.myResult,
    this.wordCloud,
  });

  factory LiveLockedData.fromJson(Map<String, dynamic> json) => LiveLockedData(
        questionId: json['question_id'] as String? ?? '',
        correctAnswer: LiveCorrectAnswer.fromJson(
            json['correct_answer'] as Map<String, dynamic>? ?? {}),
        stats: LiveQuestionStats.fromJson(
            json['stats'] as Map<String, dynamic>? ?? {}),
        myResult: json['my_result'] != null
            ? LiveStudentResult.fromJson(
                json['my_result'] as Map<String, dynamic>)
            : null,
        wordCloud: (json['word_cloud'] as List<dynamic>?)?.cast<String>(),
      );
}

class LiveLobbyParticipantJoined extends LiveWsEvent {
  final String attemptId;
  final String? userId;
  final String name;

  LiveLobbyParticipantJoined({
    required this.attemptId,
    this.userId,
    required this.name,
  });

  factory LiveLobbyParticipantJoined.fromJson(Map<String, dynamic> data) =>
      LiveLobbyParticipantJoined(
        attemptId: data['attempt_id'] as String,
        userId: data['user_id'] as String?,
        name: data['name'] as String? ?? '',
      );
}

class LiveLobbyParticipantLeft extends LiveWsEvent {
  final String attemptId;

  LiveLobbyParticipantLeft({required this.attemptId});

  factory LiveLobbyParticipantLeft.fromJson(Map<String, dynamic> data) =>
      LiveLobbyParticipantLeft(attemptId: data['attempt_id'] as String);
}

class LiveQuizStarted extends LiveWsEvent {}

class LiveQuestionStarted extends LiveWsEvent {
  final int questionIndex;
  final LiveQuestion question;
  final int timeLimitSec;
  final DateTime startedAt;
  final DateTime deadlineAt;

  LiveQuestionStarted({
    required this.questionIndex,
    required this.question,
    required this.timeLimitSec,
    required this.startedAt,
    required this.deadlineAt,
  });

  factory LiveQuestionStarted.fromJson(Map<String, dynamic> data) {
    final timeLimitSec = (data['time_limit_sec'] as num?)?.toInt() ?? 30;
    final deadlineAt = data['deadline_at'] != null
        ? DateTime.parse(data['deadline_at'] as String)
        : DateTime.now();
    final startedAt = data['started_at'] != null
        ? DateTime.parse(data['started_at'] as String)
        : deadlineAt.subtract(Duration(seconds: timeLimitSec));
    final rawIdx =
        (data['question_idx'] as num?) ?? (data['question_index'] as num?);
    final idx = _liveQuestionIndexOneBasedFromPayload(rawIdx) ?? 1;
    return LiveQuestionStarted(
      questionIndex: idx,
      question: LiveQuestion.fromJson(
          data['question'] as Map<String, dynamic>),
      timeLimitSec: timeLimitSec,
      startedAt: startedAt,
      deadlineAt: deadlineAt,
    );
  }
}

/// Teacher only
class LiveParticipantAnswered extends LiveWsEvent {
  final String attemptId;
  final String questionId;
  final bool isCorrect;
  final int timeTakenMs;

  LiveParticipantAnswered({
    required this.attemptId,
    required this.questionId,
    required this.isCorrect,
    required this.timeTakenMs,
  });

  factory LiveParticipantAnswered.fromJson(Map<String, dynamic> data) =>
      LiveParticipantAnswered(
        attemptId: data['attempt_id'] as String? ?? '',
        questionId: data['question_id'] as String? ?? '',
        isCorrect: data['is_correct'] as bool? ?? false,
        timeTakenMs: (data['time_taken_ms'] as num?)?.toInt() ?? 0,
      );
}

/// Teacher only
class LiveQuestionStatsTick extends LiveWsEvent {
  final String questionId;
  final LiveQuestionStats stats;

  LiveQuestionStatsTick({required this.questionId, required this.stats});

  factory LiveQuestionStatsTick.fromJson(Map<String, dynamic> data) {
    final statsPayload = data['stats'] as Map<String, dynamic>?;
    return LiveQuestionStatsTick(
      questionId: data['question_id'] as String? ?? '',
      stats: LiveQuestionStats.fromJson(statsPayload ?? data),
    );
  }
}

class LiveQuestionLocked extends LiveWsEvent {
  final String questionId;
  final LiveCorrectAnswer correctAnswer;
  final LiveQuestionStats stats;
  final LiveStudentResult? myResult; // null for teacher / student who didn't answer
  final List<String>? wordCloud; // only for with_given_answer

  LiveQuestionLocked({
    required this.questionId,
    required this.correctAnswer,
    required this.stats,
    this.myResult,
    this.wordCloud,
  });

  factory LiveQuestionLocked.fromJson(Map<String, dynamic> data) {
    final statsBase = data['stats'] as Map<String, dynamic>? ?? {};
    final distribution = data['distribution'] as List<dynamic>?;
    final statsPayload = Map<String, dynamic>.from(statsBase);
    if (distribution != null && distribution.isNotEmpty) {
      statsPayload['kind'] = 'choice';
      statsPayload['distribution'] = distribution;
    }
    return LiveQuestionLocked(
      questionId: data['question_id'] as String? ?? '',
      correctAnswer: LiveCorrectAnswer.fromJson(
          data['correct_answer'] as Map<String, dynamic>? ?? {}),
      stats: LiveQuestionStats.fromJson(statsPayload),
      myResult: data['my_result'] != null
          ? LiveStudentResult.fromJson(
              data['my_result'] as Map<String, dynamic>)
          : null,
      wordCloud: (data['word_cloud'] as List<dynamic>?)?.cast<String>(),
    );
  }
}

class LiveQuizCompleted extends LiveWsEvent {}

class LiveParticipantKicked extends LiveWsEvent {
  final String attemptId;
  LiveParticipantKicked({required this.attemptId});
  factory LiveParticipantKicked.fromJson(Map<String, dynamic> data) =>
      LiveParticipantKicked(attemptId: data['attempt_id'] as String);
}

class LiveYouWereKicked extends LiveWsEvent {
  final String reason;
  LiveYouWereKicked({required this.reason});
  factory LiveYouWereKicked.fromJson(Map<String, dynamic> data) =>
      LiveYouWereKicked(reason: data['reason'] as String? ?? 'kicked_by_teacher');
}

class LiveWsError extends LiveWsEvent {
  final String code;
  final String? message;
  final String? clientMsgId;

  LiveWsError({required this.code, this.message, this.clientMsgId});

  factory LiveWsError.fromJson(Map<String, dynamic> data) => LiveWsError(
        code: data['code'] as String? ?? 'UNKNOWN',
        message: data['message'] as String?,
        clientMsgId: data['client_msg_id'] as String?,
      );
}

class LiveAck extends LiveWsEvent {
  final String clientMsgId;
  LiveAck({required this.clientMsgId});
  factory LiveAck.fromJson(Map<String, dynamic> data) =>
      LiveAck(clientMsgId: data['client_msg_id'] as String);
}

class LiveWsDisconnected extends LiveWsEvent {}

// ─── Parser ──────────────────────────────────────────────────────────────────

LiveWsEvent? parseLiveWsEvent(Map<String, dynamic> json) {
  final type = json['type'] as String?;
  final data = json['data'] as Map<String, dynamic>? ?? {};
  return switch (type) {
    'state.snapshot' => LiveStateSnapshot.fromJson(json),
    'lobby.participant_joined' => LiveLobbyParticipantJoined.fromJson(data),
    'lobby.participant_left' => LiveLobbyParticipantLeft.fromJson(data),
    'quiz.started' => LiveQuizStarted(),
    'question.started' => LiveQuestionStarted.fromJson(data),
    'participant.answered' => LiveParticipantAnswered.fromJson(data),
    'question.stats_tick' => LiveQuestionStatsTick.fromJson(data),
    'question.locked' => LiveQuestionLocked.fromJson(data),
    'quiz.completed' => LiveQuizCompleted(),
    'participant.kicked' => LiveParticipantKicked.fromJson(data),
    'you_were_kicked' => LiveYouWereKicked.fromJson(data),
    'error' => LiveWsError.fromJson(data),
    'ack' => LiveAck.fromJson(data),
    _ => null,
  };
}
