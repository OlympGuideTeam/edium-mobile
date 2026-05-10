import 'package:edium/domain/entities/attempt_review.dart' show TeacherAnswerOption;
import 'package:edium/domain/entities/live_question.dart';

part 'live_results_live_attempt_review.dart';
part 'live_results_live_leaderboard_row.dart';
part 'live_results_live_results_student.dart';
part 'live_results_live_results_teacher_question.dart';
part 'live_results_live_results_teacher_attempt_answer.dart';
part 'live_results_live_results_teacher_attempt.dart';
part 'live_results_live_results_teacher.dart';


class LiveAnswerReview {
  final String submissionId;
  final String questionId;
  final String questionType;
  final String questionText;
  final Map<String, dynamic> answerData;
  final double? finalScore;
  final String? finalSource;
  final String? finalFeedback;
  final List<TeacherAnswerOption>? options;
  final Map<String, dynamic>? metadata;

  const LiveAnswerReview({
    required this.submissionId,
    required this.questionId,
    required this.questionType,
    required this.questionText,
    required this.answerData,
    this.finalScore,
    this.finalSource,
    this.finalFeedback,
    this.options,
    this.metadata,
  });

  factory LiveAnswerReview.fromJson(Map<String, dynamic> json) =>
      LiveAnswerReview(
        submissionId: json['submission_id'] as String? ?? '',
        questionId: json['question_id'] as String? ?? '',
        questionType: json['question_type'] as String? ?? '',
        questionText: json['question_text'] as String? ?? '',
        answerData: (json['answer_data'] as Map<String, dynamic>?) ?? {},
        finalScore: (json['final_score'] as num?)?.toDouble(),
        finalSource: json['final_source'] as String?,
        finalFeedback: json['final_feedback'] as String?,
        options: (json['options'] as List<dynamic>?)
            ?.map((e) => TeacherAnswerOption(
                  id: e['id'] as String? ?? '',
                  text: e['text'] as String? ?? '',
                  isCorrect: e['is_correct'] as bool? ?? false,
                ))
            .toList(),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}

