import 'dart:async';

import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:edium/services/notification_service/notification_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBadgeCubit extends Cubit<int> {
  final IHeraldApiService _heraldApiService;
  late final StreamSubscription<void> _badgeSub;
  int _generation = 0;

  NotificationBadgeCubit(
    this._heraldApiService,
    NotificationService notificationService,
  ) : super(0) {
    _badgeSub = notificationService.badgeRefreshStream.listen((_) => load());
  }

  Future<void> load() async {
    final gen = ++_generation;
    try {
      final count = await _heraldApiService.getUnreadNotificationsCount();
      if (gen == _generation) {
        emit(count);
        NotificationService.setBadgeCount(count);
      }
    } catch (_) {
      if (gen == _generation) emit(0);
    }
  }

  @override
  Future<void> close() {
    _badgeSub.cancel();
    return super.close();
  }
}
