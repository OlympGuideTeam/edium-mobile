part of 'course_detail_model.dart';

class CourseItemPayloadModel {
  final String? title;
  final String mode;
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool? shuffleQuestions;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const CourseItemPayloadModel({
    this.title,
    required this.mode,
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions,
    this.startedAt,
    this.finishedAt,
  });

  factory CourseItemPayloadModel.fromJson(Map<String, dynamic> json) {
    return CourseItemPayloadModel(
      title: json['title'] as String?,
      mode: json['mode'] as String? ?? 'test',
      totalTimeLimitSec: json['total_time_limit_sec'] as int?,
      questionTimeLimitSec: json['question_time_limit_sec'] as int?,
      shuffleQuestions: json['shuffle_questions'] as bool?,
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'] as String)
          : null,
      finishedAt: json['finished_at'] != null
          ? DateTime.tryParse(json['finished_at'] as String)
          : null,
    );
  }

  CourseItemPayload toEntity() => CourseItemPayload(
        title: title,
        mode: mode,
        totalTimeLimitSec: totalTimeLimitSec,
        questionTimeLimitSec: questionTimeLimitSec,
        shuffleQuestions: shuffleQuestions,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );
}

