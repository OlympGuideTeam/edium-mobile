import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:edium/services/herald_api_service/herald_dto.dart';
import 'package:edium/services/herald_api_service/herald_endpoints.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class HeraldApiService extends BaseApiService implements IHeraldApiService {
  HeraldApiService(super.dio);

  @override
  Future<void> registerDevice(String fcmToken, String platform) async {
    return request(
      HeraldEndpoints.devices.path,
      method: HttpMethod.post,
      req: RegisterDeviceRequest(fcmToken: fcmToken, platform: platform).toJson(),
      parser: (_) {},
    );
  }

  @override
  Future<void> unregisterDevice(String fcmToken) async {
    return request(
      heraldDeviceByToken(fcmToken),
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }

  @override
  Future<List<NotificationItem>> getNotifications() async {
    return request(
      HeraldEndpoints.notifications.path,
      method: HttpMethod.get,
      parser: (data) => (data as List)
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<void> markNotificationRead(String id) async {
    return request(
      heraldNotificationRead(id),
      method: HttpMethod.patch,
      parser: (_) {},
    );
  }
}
