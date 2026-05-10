part of 'class_detail_event.dart';

class RemoveMemberEvent extends ClassDetailEvent {
  final String userId;
  const RemoveMemberEvent(this.userId);
}

