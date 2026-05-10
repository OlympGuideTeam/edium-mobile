part of 'live_ws_event.dart';

class LiveQuestionLocked extends LiveWsEvent {
  final String questionId;
  final LiveCorrectAnswer correctAnswer;
  final LiveQuestionStats stats;
  final LiveStudentResult? myResult;
  final List<String>? wordCloud;

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

