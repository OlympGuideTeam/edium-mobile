part of 'notifications_event.dart';

class TogglePushEvent extends NotificationsEvent {
  final bool enabled;
  const TogglePushEvent(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

