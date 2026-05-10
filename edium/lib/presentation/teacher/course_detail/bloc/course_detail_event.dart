
part 'course_detail_event_load_course_detail_event.dart';
part 'course_detail_event_silent_reload_course_detail_event.dart';
part 'course_detail_event_create_module_event.dart';
part 'course_detail_event_delete_draft_event.dart';
part 'course_detail_event_reorder_modules_event.dart';
part 'course_detail_event_optimistic_quiz_added_event.dart';

abstract class CourseDetailEvent {
  const CourseDetailEvent();
}

