part of 'live_ws_event.dart';

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

