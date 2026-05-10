import 'package:edium/domain/entities/class_summary.dart';

part 'classes_state_classes_initial.dart';
part 'classes_state_classes_loading.dart';
part 'classes_state_classes_loaded.dart';
part 'classes_state_classes_error.dart';
part 'classes_state_class_created.dart';
part 'classes_state_class_create_error.dart';
part 'classes_state_class_deleted.dart';
part 'classes_state_class_delete_error.dart';


abstract class ClassesState {
  const ClassesState();
}

