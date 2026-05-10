part of 'live_ws_event.dart';

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

