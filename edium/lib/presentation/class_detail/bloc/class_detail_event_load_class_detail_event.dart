part of 'class_detail_event.dart';

class LoadClassDetailEvent extends ClassDetailEvent {
  final String classId;
  const LoadClassDetailEvent(this.classId);
}

