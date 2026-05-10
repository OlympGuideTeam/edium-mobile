import 'package:edium/domain/entities/class_detail.dart';

part 'class_detail_state_class_detail_initial.dart';
part 'class_detail_state_class_detail_loading.dart';
part 'class_detail_state_class_detail_loaded.dart';
part 'class_detail_state_class_detail_error.dart';
part 'class_detail_state_class_not_found.dart';
part 'class_detail_state_class_title_updated.dart';
part 'class_detail_state_class_deleted.dart';
part 'class_detail_state_member_removed.dart';
part 'class_detail_state_invite_link_copied.dart';
part 'class_detail_state_course_deleted.dart';
part 'class_detail_state_class_detail_action_error.dart';


abstract class ClassDetailState {
  const ClassDetailState();
}

