import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:edium/services/herald_api_service/herald_dto.dart';

class HeraldApiServiceMock implements IHeraldApiService {
  @override
  Future<void> registerDevice(String fcmToken, String platform) async {}

  @override
  Future<void> unregisterDevice(String fcmToken) async {}

  @override
  Future<List<NotificationItem>> getNotifications() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return [
      NotificationItem(
        id: 'notif-1',
        title: 'Новый квиз назначен',
        body: 'Учитель назначил квиз в классе 7А — Математика',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        isRead: false,
        route: '/class/class-1',
      ),
      NotificationItem(
        id: 'notif-2',
        title: 'Курс обновлён',
        body: 'В курсе «Алгебра 7 класс» появились новые материалы',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        isRead: false,
        route: '/course/course-1',
      ),
      NotificationItem(
        id: 'notif-3',
        title: 'Результаты квиза готовы',
        body: 'Ваш результат по квизу «Функции» — 85/100',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        route: null,
      ),
    ];
  }

  @override
  Future<int> getUnreadNotificationsCount() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final items = await getNotifications();
    return items.where((n) => !n.isRead).length;
  }

  @override
  Future<void> markNotificationRead(String id) async {}
}
