enum HeraldEndpoints {
  devices('herald/v1/devices'),
  notifications('herald/v1/notifications'),
  notificationsCount('herald/v1/notifications/count');

  final String path;
  const HeraldEndpoints(this.path);
}

String heraldDeviceByToken(String token) =>
    'herald/v1/devices/${Uri.encodeComponent(token)}';

String heraldNotificationRead(String id) =>
    'herald/v1/notifications/$id/read';
