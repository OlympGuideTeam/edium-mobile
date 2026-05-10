import 'package:edium/domain/entities/course_detail.dart';

part 'course_detail_state_course_detail_initial.dart';
part 'course_detail_state_course_detail_loading.dart';
part 'course_detail_state_course_detail_loaded.dart';
part 'course_detail_state_course_detail_error.dart';
part 'course_detail_state_course_module_created.dart';
part 'course_detail_state_course_detail_action_error.dart';
part 'course_detail_state_course_draft_deleted.dart';


abstract class CourseDetailState {
  const CourseDetailState();
}

