abstract class CourseDetailEvent {
  const CourseDetailEvent();
}

class LoadCourseDetailEvent extends CourseDetailEvent {
  final String courseId;
  const LoadCourseDetailEvent(this.courseId);
}

/// Reload without showing the loading spinner.
class SilentReloadCourseDetailEvent extends CourseDetailEvent {
  final String courseId;
  const SilentReloadCourseDetailEvent(this.courseId);
}

class CreateModuleEvent extends CourseDetailEvent {
  final String title;
  const CreateModuleEvent(this.title);
}

class DeleteDraftEvent extends CourseDetailEvent {
  final String draftId;
  const DeleteDraftEvent(this.draftId);
}

class ReorderModulesEvent extends CourseDetailEvent {
  final List<String> moduleIds;
  const ReorderModulesEvent(this.moduleIds);
}

/// Optimistically patches the in-memory CourseDetail after a quiz is created,
/// without triggering a loading spinner.
/// [moduleId] == null → saveOnly path (quiz becomes a draft).
/// [moduleId] != null → session created in that module.
/// [existingTemplateId] != null → draft was being edited; remove it from drafts.
class OptimisticQuizAddedEvent extends CourseDetailEvent {
  final String title;
  final String mode; // 'test' | 'live'
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
