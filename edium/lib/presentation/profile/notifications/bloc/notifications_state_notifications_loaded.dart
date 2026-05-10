part of 'notifications_state.dart';

class NotificationsLoaded extends NotificationsState {
  final bool pushEnabled;
  final List<NotificationItem> items;
  final bool shouldOpenSettings;

  const NotificationsLoaded({
    required this.pushEnabled,
    required this.items,
    this.shouldOpenSettings = false,
  });

  NotificationsLoaded copyWith({
    bool? pushEnabled,
    List<NotificationItem>? items,
    bool? shouldOpenSettings,
  }) {
    return NotificationsLoaded(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      items: items ?? this.items,
      shouldOpenSettings: shouldOpenSettings ?? false,
    );
  }

  @override
  List<Object?> get props => [pushEnabled, items, shouldOpenSettings];
}

