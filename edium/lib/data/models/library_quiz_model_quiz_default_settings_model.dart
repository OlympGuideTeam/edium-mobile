part of 'library_quiz_model.dart';

class QuizDefaultSettingsModel {
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool? shuffleQuestions;

  const QuizDefaultSettingsModel({
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions,
  });

  factory QuizDefaultSettingsModel.fromJson(Map<String, dynamic> json) {
    return QuizDefaultSettingsModel(
      totalTimeLimitSec: json['total_time_limit_sec'] as int?,
      questionTimeLimitSec: json['question_time_limit_sec'] as int?,
      shuffleQuestions: json['shuffle_questions'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (totalTimeLimitSec != null)
          'total_time_limit_sec': totalTimeLimitSec,
        if (questionTimeLimitSec != null)
          'question_time_limit_sec': questionTimeLimitSec,
        if (shuffleQuestions != null) 'shuffle_questions': shuffleQuestions,
      };

  QuizDefaultSettings toEntity() => QuizDefaultSettings(
        totalTimeLimitSec: totalTimeLimitSec,
        questionTimeLimitSec: questionTimeLimitSec,
        shuffleQuestions: shuffleQuestions,
      );
}

