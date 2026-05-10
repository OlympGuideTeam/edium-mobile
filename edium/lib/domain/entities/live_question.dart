import 'package:edium/domain/entities/question.dart';

part 'live_question_live_question.dart';
part 'live_question_live_option_distribution.dart';
part 'live_question_live_question_stats.dart';
part 'live_question_live_choice_stats.dart';
part 'live_question_live_binary_stats.dart';
part 'live_question_live_correct_answer.dart';
part 'live_question_live_student_result.dart';


class LiveAnswerOption {
  final String id;
  final String text;
  final bool? isCorrect;

  const LiveAnswerOption({
    required this.id,
    required this.text,
    this.isCorrect,
  });

  factory LiveAnswerOption.fromJson(Map<String, dynamic> json) =>
      LiveAnswerOption(
        id: json['id'] as String,
        text: json['text'] as String? ?? '',
        isCorrect: json['is_correct'] as bool?,
      );
}

