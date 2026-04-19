import 'package:edium/services/herald_api_service/herald_dto.dart';
import 'package:equatable/equatable.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

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

class NotificationsError extends NotificationsState {
  final String message;
  const NotificationsError(this.message);

  @override
  List<Object?> get props => [message];
}
