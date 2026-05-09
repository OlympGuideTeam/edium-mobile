import 'dart:io';

import 'package:edium/presentation/profile/notifications/bloc/notifications_event.dart';
import 'package:edium/presentation/profile/notifications/bloc/notifications_state.dart';
import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:edium/services/herald_api_service/herald_dto.dart';
import 'package:edium/services/notification_service/notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsBloc
    extends Bloc<NotificationsEvent, NotificationsState> {
  final IHeraldApiService heraldApiService;
  final NotificationService notificationService;

  NotificationsBloc({
    required this.heraldApiService,
    required this.notificationService,
  }) : super(const NotificationsInitial()) {
    on<LoadNotificationsEvent>(_onLoad);
    on<TogglePushEvent>(_onTogglePush);
    on<MarkReadEvent>(_onMarkRead);
  }

  Future<void> _onLoad(
    LoadNotificationsEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      final status = await notificationService.getPermissionStatus();
      final pushEnabled = status == AuthorizationStatus.authorized ||
          status == AuthorizationStatus.provisional;

      final items = await heraldApiService.getNotifications();
      emit(NotificationsLoaded(pushEnabled: pushEnabled, items: items));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onTogglePush(
    TogglePushEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    try {
      if (event.enabled) {
        final currentStatus = await notificationService.getPermissionStatus();

        // Already denied — can't re-request, must open Settings
        if (currentStatus == AuthorizationStatus.denied) {
          emit(current.copyWith(shouldOpenSettings: true));
          return;
        }

        final settings = await notificationService.requestPermission();
        final granted = settings.authorizationStatus ==
                AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

        if (!granted) {
          emit(current.copyWith(shouldOpenSettings: true));
          return;
        }

        emit(current.copyWith(pushEnabled: true));
        final token = await notificationService.getToken();
        if (token != null) {
          final platform = Platform.isIOS ? 'ios' : 'android';
          await heraldApiService.registerDevice(token, platform);
        }
      } else {
        emit(current.copyWith(pushEnabled: false));
        final token = await notificationService.getToken();
        if (token != null) {
          await heraldApiService.unregisterDevice(token);
        }
      }
    } catch (_) {
      emit(current);
    }
  }

  Future<void> _onMarkRead(
    MarkReadEvent event,
    Emitter<NotificationsState> emit,
  ) async {
    final current = state;
    if (current is! NotificationsLoaded) return;

    // Optimistic update
    final updated = current.items.map((item) {
      if (item.id == event.notificationId) {
        return NotificationItem(
          id: item.id,
          title: item.title,
          body: item.body,
          createdAt: item.createdAt,
          isRead: true,
          route: item.route,
          role: item.role,
        );
      }
      return item;
    }).toList();
    emit(current.copyWith(items: updated));

    try {
      await heraldApiService.markNotificationRead(event.notificationId);
      notificationService.triggerBadgeRefresh();
    } catch (_) {
      // Revert on error
      emit(current);
    }
  }
}
