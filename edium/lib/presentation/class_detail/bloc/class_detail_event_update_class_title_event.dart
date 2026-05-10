part of 'class_detail_event.dart';

class UpdateClassTitleEvent extends ClassDetailEvent {
  final String newTitle;
  const UpdateClassTitleEvent(this.newTitle);
}

