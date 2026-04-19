import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotificationsEvent extends NotificationsEvent {
  const LoadNotificationsEvent();
}

class TogglePushEvent extends NotificationsEvent {
  final bool enabled;
  const TogglePushEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class MarkReadEvent extends NotificationsEvent {
  final String notificationId;
  const MarkReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}
