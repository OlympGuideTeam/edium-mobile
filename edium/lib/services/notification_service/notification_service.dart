import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'notification_service_notification_service.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {

}

const _androidChannel = AndroidNotificationChannel(
  'edium_notifications',
  'Edium Уведомления',
  description: 'Уведомления о квизах, классах и курсах',
  importance: Importance.high,
);

class NotificationTapData {
  final String route;
  final String? role;
  final String? messageId;
  final String? notificationId;

  const NotificationTapData({
    required this.route,
    this.role,
    this.messageId,
    this.notificationId,
  });
}

