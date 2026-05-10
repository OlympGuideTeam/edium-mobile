import 'package:equatable/equatable.dart';

part 'create_course_event_update_course_title_event.dart';
part 'create_course_event_add_module_event.dart';
part 'create_course_event_update_module_event.dart';
part 'create_course_event_remove_module_event.dart';
part 'create_course_event_reorder_modules_event.dart';
part 'create_course_event_submit_course_event.dart';


abstract class CreateCourseEvent extends Equatable {
  const CreateCourseEvent();
  @override
  List<Object?> get props => [];
}

