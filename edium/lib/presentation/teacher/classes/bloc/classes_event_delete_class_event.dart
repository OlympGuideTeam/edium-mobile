part of 'classes_event.dart';

class DeleteClassEvent extends ClassesEvent {
  final String classId;

  const DeleteClassEvent(this.classId);
}

