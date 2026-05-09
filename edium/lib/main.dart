import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/core/router/app_router.dart' show buildRouter;
import 'package:edium/core/storage/hive_storage.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_theme.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/firebase_options.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:edium/services/navigation_block_service/navigation_block_service.dart';
import 'package:edium/services/notification_service/deep_link_service.dart';
import 'package:edium/services/notification_service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final ValueNotifier<int> appRestartKey = ValueNotifier(0);

// Dedup by messageId only — catches the same FCM message arriving via
// multiple paths (e.g., onMessageOpenedApp + getInitialMessage on terminated
// launch). LRU-capped at 32. Earlier we also deduped by route+role, but
// that blocked legitimate repeat taps with the same content.
final _processedMessageIds = <String>{};

// Ensures only one cold-start subscription is created even if the same
// notification fires through multiple FCM paths (onMessageOpenedApp +
// getInitialMessage) with null or mismatched messageIds.
bool _coldStartHandled = false;

// Used to suppress the late Android onMessageOpenedApp duplicate that fires
// after the cold-start tap has already been handled.
final DateTime _appStartTime = DateTime.now();

void _handleNotificationTap({
  required String route,
  required String? role,
  required String? messageId,
  required bool wasInForeground,
  String? notificationId,
  bool fromTerminatedLaunch = false,
}) {
  if (messageId != null) {
    if (_processedMessageIds.contains(messageId)) return;
    _processedMessageIds.add(messageId);
    if (_processedMessageIds.length > 32) {
      _processedMessageIds.remove(_processedMessageIds.first);
    }
  }

  if (notificationId != null) {
    getIt<IHeraldApiService>()
        .markNotificationRead(notificationId)
        .catchError((_) {});
  }

  final state = getIt<AuthBloc>().state;
  final isColdStart = fromTerminatedLaunch || state is! AuthAuthenticated;

  // NavigationBlockService applies only to live taps — on cold start there's
  // no sensitive screen yet.
  if (!isColdStart && getIt<NavigationBlockService>().isBlocked) return;

  // For cold start (terminated launch): navigate to the actual target route
  // with a role switch if needed. The wasReceivedInForeground check is
  // unreliable here — on Android, FCM can replay the message through onMessage
  // during startup (adding the messageId to _foregroundMessageIds before
  // onMessageOpenedApp fires), making wasInForeground appear true even though
  // the app was not actually in the foreground.
  if (isColdStart) {
    if (_coldStartHandled) return; // multiple FCM paths, deduplicate
    _coldStartHandled = true;
    debugPrint('[Notif] cold-start tap → route=$route role=$role, waiting for auth');

    final capturedRoute = route;
    final capturedRole = role;

    if (state is AuthAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint('[Notif] cold-start already authed, routing to $capturedRoute');
        _routeOrSwitch(state, route: capturedRoute, role: capturedRole);
      });
      return;
    }

    late StreamSubscription<AuthState> sub;
    sub = getIt<AuthBloc>().stream.listen((s) {
      if (s is AuthAuthenticated) {
        sub.cancel();
        // Wait for GoRouter's auth-redirect frame to settle before setting
        // the pending route — avoids "nothing to pop" errors in go_router v14.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('[Notif] cold-start auth ready, routing to $capturedRoute');
          _routeOrSwitch(s, route: capturedRoute, role: capturedRole);
        });
      }
    });
    return;
  }

  // Android: onMessageOpenedApp fires late during startup (after cold-start
  // was already processed) because FCM replays onMessage first, making the
  // tap appear as a foreground event. Suppress within the startup window.
  if (_coldStartHandled &&
      DateTime.now().difference(_appStartTime).inSeconds < 10) {
    debugPrint('[Notif] startup-window dedup, skipping duplicate live tap');
    return;
  }

  // Live tap: приложение уже было запущено (foreground или background).
  // Тап из шторки ведёт в тот же маршрут и роль, что и баннер в foreground /
  // cold start — _routeOrSwitch синхронизирует роль перед setPendingRoute.
  if (route.isEmpty) return;

  debugPrint('[Notif] live tap route=$route role=$role mid=$messageId '
      'wasFG=$wasInForeground');

  _routeOrSwitch(state, route: route, role: role);
}

const _iosLaunchNotificationChannel =
    MethodChannel('edium/launch_notification');

/// Fallback при UIScene: тап по FCM лежит в `SceneDelegate.connectionOptions`, см. AppDelegate.swift.
Future<Map<String, String>?> _consumeIosNativePendingLaunch({
  int attempts = 1,
  Duration delay = Duration.zero,
}) async {
  for (var i = 0; i < attempts; i++) {
    try {
      final raw = await _iosLaunchNotificationChannel
          .invokeMethod<dynamic>('consumePendingLaunchNotification');
      if (raw is Map) {
        final map = <String, String>{};
        for (final e in raw.entries) {
          final v = e.value;
          map[e.key.toString()] = v == null ? '' : v.toString();
        }
        final route = map['route'];
        if (route != null && route.isNotEmpty) return map;
      }
    } catch (e) {
      debugPrint('[Notif] iOS native launch channel not ready ($i): $e');
    }
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
  }
  return null;
}

void _handleRemoteMessageTap(
  RemoteMessage message, {
  bool fromTerminatedLaunch = false,
}) {
  final route = message.data['route']?.toString();
  final role = message.data['role']?.toString();
  final nid = message.data['notification_id']?.toString();
  if (route == null || route.isEmpty) return;
  _handleNotificationTap(
    route: route,
    role: role,
    messageId: message.messageId,
    notificationId: nid,
    wasInForeground: false,
    fromTerminatedLaunch: fromTerminatedLaunch,
  );
}

Future<void> _resolveIosTerminatedTapFallback() async {
  debugPrint('[Notif] iOS fallback resolver started');
  for (var i = 0; i < 40; i++) {
    final m = await FirebaseMessaging.instance.getInitialMessage();
    if (m != null) {
      debugPrint('[Notif] iOS delayed getInitialMessage resolved on try #$i');
      _handleRemoteMessageTap(m, fromTerminatedLaunch: true);
      return;
    }

    final native = await _consumeIosNativePendingLaunch();
    final route = native?['route'];
    if (native != null && route != null && route.isNotEmpty) {
      final roleRaw = native['role'];
      final midRaw = native['messageId'];
      debugPrint('[Notif] cold start from native Scene tap route=$route try #$i');
      final nidRaw = native['notification_id'];
      _handleNotificationTap(
        route: route,
        role: (roleRaw == null || roleRaw.isEmpty) ? null : roleRaw,
        messageId: (midRaw == null || midRaw.isEmpty) ? null : midRaw,
        notificationId: (nidRaw == null || nidRaw.isEmpty) ? null : nidRaw,
        wasInForeground: false,
        fromTerminatedLaunch: true,
      );
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  debugPrint('[Notif] iOS fallback resolver finished without launch payload');
}

void _routeOrSwitch(
  AuthAuthenticated state, {
  required String route,
  required String? role,
}) {
  if (role != null) {
    final cur = state.user.role;
    final needsSwitch = (role == 'student' && cur != UserRole.student) ||
        (role == 'teacher' && cur != UserRole.teacher);
    debugPrint('[Notif] _routeOrSwitch route=$route role=$role cur=$cur needsSwitch=$needsSwitch');
    // Encode role into the URL so the route builder can read isTeacher/isStudent
    // from query params when extra is unavailable (deep link navigation).
    final routeWithRole = _routeWithRole(route, role);
    if (needsSwitch) {
      getIt<AuthBloc>().add(SwitchToRoleEvent(role));
      // Wait for the role to actually switch in state before setting the
      // pending route — avoids a race where _redirect consumes the route
      // before the new role is reflected in _homeRoute.
      StreamSubscription<AuthState>? sub;
      sub = getIt<AuthBloc>().stream.listen((s) {
        if (s is AuthAuthenticated) {
          final expected = role == 'teacher' ? UserRole.teacher : UserRole.student;
          if (s.user.role == expected) {
            sub?.cancel();
            getIt<DeepLinkService>().setPendingRoute(routeWithRole);
          }
        }
      });
      return;
    }
    getIt<DeepLinkService>().setPendingRoute(routeWithRole);
    return;
  }
  debugPrint('[Notif] _routeOrSwitch route=$route role=null');
  getIt<DeepLinkService>().setPendingRoute(route);
}

String _routeWithRole(String route, String role) {
  final uri = Uri.parse(route);
  final params = Map<String, String>.from(uri.queryParameters);
  params['role'] = role;
  return uri.replace(queryParameters: params).toString();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await HiveStorage.init();

  if (!ApiConfig.isStoreBuild) {
    ApiConfig.environment = ProfileStorage.loadEnvironment();
  }

  NotificationService? notificationService;
  final deepLinkService = DeepLinkService();
  RemoteMessage? initialMessage;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Must be called BEFORE initialize() — on iOS, registering the
    // onMessageOpenedApp listener inside initialize() can consume the
    // terminated-launch notification event, leaving getInitialMessage()
    // returning null.
    initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    notificationService = NotificationService();
    await notificationService.initialize();
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  // Universal links (iOS) / App Links (Android)
  // https://links.edium.online/invite/<token> → /invite/<token>
  final appLinks = AppLinks();
  try {
    final initialUri = await appLinks.getInitialLink();
    if (initialUri != null) {
      final route = _parseDeepLinkUri(initialUri);
      if (route != null) deepLinkService.setPendingRoute(route);
    }
  } catch (_) {}

  await initializeDependencies(
    notificationService: notificationService ?? NotificationService(),
    deepLinkService: deepLinkService,
  );

  // Universal links while app is running (foreground/background).
  appLinks.uriLinkStream.listen((uri) {
    debugPrint('[DeepLink] uriLinkStream received: $uri');
    final route = _parseDeepLinkUri(uri);
    debugPrint('[DeepLink] parsed route: $route');
    if (route != null) getIt<DeepLinkService>().setPendingRoute(route);
  });

  // Wire live tap listener BEFORE dispatching AppStarted: on iOS terminated
  // launch onMessageOpenedApp may fire while auth is still loading, and
  // _handleNotificationTap is set up to defer until AuthAuthenticated.
  final ns = notificationService;
  if (ns != null) {
    ns.tapStream.listen((tap) {
      _handleNotificationTap(
        route: tap.route,
        role: tap.role,
        messageId: tap.messageId,
        notificationId: tap.notificationId,
        wasInForeground: ns.wasReceivedInForeground(tap.messageId),
      );
    });
    // iOS terminated: onMessageOpenedApp can fire during initialize() — before
    // we reach this line — and broadcast streams drop events without
    // listeners. NotificationService buffers them in _earlyTaps; flush now.
    ns.flushEarlyTaps();
  }

  // Terminated-launch tap via getInitialMessage. App was killed → not in
  // foreground → wasInForeground:false. Dedup by messageId protects us if
  // onMessageOpenedApp also fires for the same message.
  if (initialMessage != null) {
    _handleRemoteMessageTap(initialMessage, fromTerminatedLaunch: true);
  } else if (Platform.isIOS) {
    // Важно: не блокируем runApp на iOS fallback, иначе cold start даёт
    // несколько секунд белого экрана. Резолвим tap асинхронно.
    unawaited(_resolveIosTerminatedTapFallback());
  }

  debugPrint('[Boot] calling runApp (AppStarted после первого кадра)');
  runApp(
    ValueListenableBuilder<int>(
      valueListenable: appRestartKey,
      builder: (_, key, __) => EdiumApp(key: ValueKey(key)),
    ),
  );

  // Роутер и окно уже существуют до смены AuthInitial → AuthLoading/…,
  // иначе go_router + scene lifecycle на iOS иногда не успевают отрисовать
  // первый маршрут (белый экран до hot restart).
  WidgetsBinding.instance.addPostFrameCallback((_) {
    debugPrint('[Boot] dispatching AppStarted');
    getIt<AuthBloc>().add(const AppStarted());
  });
}

// https://links.edium.online/invite/{token} → /invite/{token}
String? _parseDeepLinkUri(Uri uri) {
  if (uri.host != 'links.edium.online') return null;
  final segments = uri.pathSegments;
  if (segments.length == 2 && segments[0] == 'invite') {
    return '/invite/${segments[1]}';
  }
  return null;
}

class EdiumApp extends StatelessWidget {
  const EdiumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: MaterialApp.router(
        title: 'Edium',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: buildRouter(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ru', 'RU'),
        ],
        locale: const Locale('ru', 'RU'),
      ),
    );
  }
}
