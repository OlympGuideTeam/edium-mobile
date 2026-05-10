part of 'notifications_event.dart';

class MarkReadEvent extends NotificationsEvent {
  final String notificationId;
  const MarkReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

