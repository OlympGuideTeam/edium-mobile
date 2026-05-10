part of 'live_ws_event.dart';

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

