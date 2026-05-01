import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background messages are shown automatically by FCM when app is in background.
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

  const NotificationTapData({
    required this.route,
    this.role,
    this.messageId,
  });
}

class NotificationService with WidgetsBindingObserver {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Lifecycle tracking — used to detect "retroactive" onMessage calls that
  // fire when the app comes to foreground via a background-notification tap.
  // _lastResumeTime is updated only on transitions paused/inactive → resumed
  // (NOT the initial launch resumed state).
  AppLifecycleState? _previousLifecycleState;
  DateTime _lastResumeTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _previousLifecycleState != null &&
        _previousLifecycleState != AppLifecycleState.resumed) {
      _lastResumeTime = DateTime.now();
      debugPrint('[Notif] lifecycle: resumed from $_previousLifecycleState');
    }
    _previousLifecycleState = state;
  }

  bool get _justResumed {
    return DateTime.now().difference(_lastResumeTime).inMilliseconds < 1500;
  }

  // Broadcast stream so the same route can fire multiple times (Fix 3)
  final _tapController = StreamController<NotificationTapData>.broadcast();
  Stream<NotificationTapData> get tapStream => _tapController.stream;

  // Buffer for taps received before any listener attached. This matters on
  // iOS terminated: onMessageOpenedApp may fire during initialize() (before
  // main.dart wires the listener), and broadcast streams drop events with
  // no subscribers. Call flushEarlyTaps() right after .listen().
  final _earlyTaps = <NotificationTapData>[];

  void _emitTap(NotificationTapData tap) {
    if (_tapController.hasListener) {
      _tapController.add(tap);
    } else {
      _earlyTaps.add(tap);
    }
  }

  void flushEarlyTaps() {
    if (_earlyTaps.isEmpty) return;
    final taps = List.of(_earlyTaps);
    _earlyTaps.clear();
    for (final tap in taps) {
      _tapController.add(tap);
    }
  }

  // Tracks messageIds that arrived via onMessage (i.e., the app was in
  // foreground when FCM delivered them). Used to distinguish a foreground
  // tap from a background tap — both surface as onMessageOpenedApp but the
  // app should react differently. LRU-capped at 32 entries.
  final _foregroundMessageIds = <String>{};

  bool wasReceivedInForeground(String? messageId) {
    if (messageId == null) return false;
    return _foregroundMessageIds.contains(messageId);
  }

  late final Stream<String> tokenRefreshStream;

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    tokenRefreshStream = _fcm.onTokenRefresh;

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_androidChannel);
    }

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // iOS: let FCM auto-display messages with notification block in
    // foreground. We skip _onForegroundMessage for those to avoid duplicate.
    // Android: FCM never auto-shows in foreground, so we always show local.
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageTap);
  }

  Future<NotificationSettings> requestPermission() {
    return _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<AuthorizationStatus> getPermissionStatus() async {
    final settings = await _fcm.getNotificationSettings();
    return settings.authorizationStatus;
  }

  Future<String?> getToken() async {
    final token = await _fcm.getToken();
    if (kDebugMode && token != null) {
      debugPrint('┌─────────────────────────────────────────┐');
      debugPrint('│ FCM TOKEN                               │');
      debugPrint('│ $token');
      debugPrint('└─────────────────────────────────────────┘');
    }
    return token;
  }

  void _onForegroundMessage(RemoteMessage message) {
    final mid = message.messageId;

    // iOS (and sometimes Android) fires onMessage retroactively when the app
    // resumes from a background tap. Filter these out — if we just resumed
    // from background, this is a tap-induced delivery, not a real foreground
    // arrival. Show was already handled by the system.
    if (_justResumed) {
      debugPrint('[Notif] onMessage SKIP retroactive mid=$mid '
          '(resumed ${DateTime.now().difference(_lastResumeTime).inMilliseconds}ms ago)');
      return;
    }

    debugPrint('[Notif] onMessage mid=$mid lifecycle=$_previousLifecycleState');

    // Track foreground arrival so a later tap can be classified as
    // foreground (banner tap) vs. background (notification-center tap).
    if (mid != null) {
      _foregroundMessageIds.add(mid);
      if (_foregroundMessageIds.length > 32) {
        _foregroundMessageIds.remove(_foregroundMessageIds.first);
      }
    }

    // On iOS, FCM auto-displays messages with notification block in foreground
    // (via setForegroundNotificationPresentationOptions). Skip to avoid
    // duplicate banner. Tap is handled by onMessageOpenedApp.
    if (Platform.isIOS && message.notification != null) return;

    // Android: always need to show manually. Data-only on iOS: FCM doesn't
    // auto-show, so show manually too.
    final title = message.notification?.title ?? message.data['title'] as String?;
    final body  = message.notification?.body  ?? message.data['body']  as String?;
    if (title == null) return;

    final route = message.data['route']?.toString();
    final role  = message.data['role']?.toString();

    // Encode route + role + messageId in the local notification payload.
    final payload = route != null
        ? jsonEncode({
            'route': route,
            if (role != null) 'role': role,
            if (mid != null) 'mid': mid,
          })
        : null;

    _localNotifications.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBadge: true,
        ),
      ),
      payload: payload,
    );
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final raw = response.payload;
    debugPrint('[Notif] _onLocalNotificationTap payload=$raw');
    if (raw == null || raw.isEmpty) return;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final route = map['route'] as String?;
      if (route != null) {
        _emitTap(NotificationTapData(
          route: route,
          role: map['role']?.toString(),
          messageId: map['mid']?.toString(),
        ));
      }
    } catch (_) {
      // Fallback: payload was a plain route string (legacy)
      _emitTap(NotificationTapData(route: raw));
    }
  }

  void _onMessageTap(RemoteMessage message) {
    final route = message.data['route']?.toString();
    final mid = message.messageId;
    debugPrint('[Notif] onMessageOpenedApp mid=$mid route="$route" '
        'inFGSet=${_foregroundMessageIds.contains(mid)} '
        'lifecycle=$_previousLifecycleState');
    if (route == null || route.isEmpty) return;
    _emitTap(NotificationTapData(
      route: route,
      role: message.data['role']?.toString(),
      messageId: mid,
    ));
  }

  void dispose() {
    _tapController.close();
  }
}
