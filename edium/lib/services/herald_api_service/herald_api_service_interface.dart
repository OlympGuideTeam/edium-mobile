import 'package:edium/services/herald_api_service/herald_dto.dart';

abstract class IHeraldApiService {
  Future<void> registerDevice(String fcmToken, String platform);
  Future<void> unregisterDevice(String fcmToken);
  Future<List<NotificationItem>> getNotifications();
  Future<int> getUnreadNotificationsCount();
  Future<void> markNotificationRead(String id);
}
