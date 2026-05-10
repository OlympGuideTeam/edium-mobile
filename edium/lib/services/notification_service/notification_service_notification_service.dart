part of 'notification_service.dart';

class NotificationService with WidgetsBindingObserver {
  static const _badgeChannel = MethodChannel('edium/badge');

  static Future<void> setBadgeCount(int count) async {
    if (!Platform.isIOS) return;
    try {
      await _badgeChannel.invokeMethod<void>('setBadgeCount', count);
    } catch (_) {}
  }

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();


  AppLifecycleState? _previousLifecycleState;
  DateTime _lastResumeTime = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _previousLifecycleState != null &&
        _previousLifecycleState != AppLifecycleState.resumed) {
      _lastResumeTime = DateTime.now();
      _badgeRefreshController.add(null);
      debugPrint('[Notif] lifecycle: resumed from $_previousLifecycleState');
    }
    _previousLifecycleState = state;
  }

  bool get _justResumed {
    return DateTime.now().difference(_lastResumeTime).inMilliseconds < 1500;
  }


  final _tapController = StreamController<NotificationTapData>.broadcast();
  Stream<NotificationTapData> get tapStream => _tapController.stream;


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


  final _foregroundMessageIds = <String>{};

  bool wasReceivedInForeground(String? messageId) {
    if (messageId == null) return false;
    return _foregroundMessageIds.contains(messageId);
  }

  final _badgeRefreshController = StreamController<void>.broadcast();
  Stream<void> get badgeRefreshStream => _badgeRefreshController.stream;

  void triggerBadgeRefresh() => _badgeRefreshController.add(null);

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


    if (_justResumed) {
      debugPrint('[Notif] onMessage SKIP retroactive mid=$mid '
          '(resumed ${DateTime.now().difference(_lastResumeTime).inMilliseconds}ms ago)');
      return;
    }

    debugPrint('[Notif] onMessage mid=$mid lifecycle=$_previousLifecycleState');


    if (mid != null) {
      _foregroundMessageIds.add(mid);
      if (_foregroundMessageIds.length > 32) {
        _foregroundMessageIds.remove(_foregroundMessageIds.first);
      }
    }


    if (Platform.isIOS && message.notification != null) return;


    final title = message.notification?.title ?? message.data['title'] as String?;
    final body  = message.notification?.body  ?? message.data['body']  as String?;


    if (title == null) {
      _badgeRefreshController.add(null);
      return;
    }

    final route = message.data['route']?.toString();
    final role  = message.data['role']?.toString();
    final nid   = message.data['notification_id']?.toString();


    final payload = route != null
        ? jsonEncode({
            'route': route,
            if (role != null) 'role': role,
            if (mid != null) 'mid': mid,
            if (nid != null) 'notification_id': nid,
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
          notificationId: map['notification_id']?.toString(),
        ));
      }
    } catch (_) {

      _emitTap(NotificationTapData(route: raw));
    }
  }

  void _onMessageTap(RemoteMessage message) {
    final route = message.data['route']?.toString();
    final mid = message.messageId;
    final nid = message.data['notification_id']?.toString();
    debugPrint('[Notif] onMessageOpenedApp mid=$mid route="$route" '
        'inFGSet=${_foregroundMessageIds.contains(mid)} '
        'lifecycle=$_previousLifecycleState');
    if (route == null || route.isEmpty) return;
    _emitTap(NotificationTapData(
      route: route,
      role: message.data['role']?.toString(),
      messageId: mid,
      notificationId: nid,
    ));
  }

  void dispose() {
    _tapController.close();
    _badgeRefreshController.close();
  }
}

