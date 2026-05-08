import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationBadgeCubit extends Cubit<int> {
  final IHeraldApiService _heraldApiService;

  NotificationBadgeCubit(this._heraldApiService) : super(0);

  Future<void> load() async {
    try {
      final items = await _heraldApiService.getNotifications();
      emit(items.where((n) => !n.isRead).length);
    } catch (_) {
      emit(0);
    }
  }
}
