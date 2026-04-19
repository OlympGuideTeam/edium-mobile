class RegisterDeviceRequest {
  final String fcmToken;
  final String platform;

  const RegisterDeviceRequest({required this.fcmToken, required this.platform});

  Map<String, dynamic> toJson() => {
        'fcm_token': fcmToken,
        'platform': platform,
      };
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final String? route;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isRead,
    this.route,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool,
      route: data?['route'] as String?,
    );
  }
}
