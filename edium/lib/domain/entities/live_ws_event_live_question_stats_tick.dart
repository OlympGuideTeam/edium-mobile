part of 'live_ws_event.dart';

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

