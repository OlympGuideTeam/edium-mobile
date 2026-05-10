part of 'course_detail_event.dart';

class DeleteDraftEvent extends CourseDetailEvent {
  final String draftId;
  const DeleteDraftEvent(this.draftId);
}

