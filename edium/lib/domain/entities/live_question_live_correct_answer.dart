part of 'live_question.dart';

class LiveCorrectAnswer {
  final Map<String, dynamic> data;

  const LiveCorrectAnswer(this.data);

  factory LiveCorrectAnswer.fromJson(Map<String, dynamic> json) =>
      LiveCorrectAnswer(json);

  String? get correctOptionId => data['correct_option_id'] as String?;
  List<String>? get correctOptionIds =>
      (data['correct_option_ids'] as List<dynamic>?)?.cast<String>();
  List<String>? get correctAnswers =>
      (data['correct_answers'] as List<dynamic>?)?.cast<String>();
  List<String>? get correctOrder =>
      (data['correct_order'] as List<dynamic>?)?.cast<String>();
  Map<String, String>? get correctPairs =>
      (data['correct_pairs'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String));
}

