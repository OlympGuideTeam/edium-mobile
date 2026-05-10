part of 'course_detail_event.dart';

class OptimisticQuizAddedEvent extends CourseDetailEvent {
  final String title;
  final String mode;
  final String? moduleId;
  final String? existingTemplateId;
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool shuffleQuestions;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const OptimisticQuizAddedEvent({
    required this.title,
    required this.mode,
    this.moduleId,
    this.existingTemplateId,
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    required this.shuffleQuestions,
    this.startedAt,
    this.finishedAt,
  });
}

