import 'dart:async';

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
import 'package:edium/services/navigation_block_service/navigation_block_service.dart';
import 'package:edium/services/notification_service/deep_link_service.dart';
import 'package:edium/services/notification_service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final ValueNotifier<int> appRestartKey = ValueNotifier(0);

const _notificationsTabRoute = '/profile/notifications';

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
}) {
  if (messageId != null) {
    if (_processedMessageIds.contains(messageId)) return;
    _processedMessageIds.add(messageId);
    if (_processedMessageIds.length > 32) {
      _processedMessageIds.remove(_processedMessageIds.first);
    }
  }

  final state = getIt<AuthBloc>().state;
  final isColdStart = state is! AuthAuthenticated;

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

  // Live tap (foreground / background, app was already running).
  // Only foreground taps deep-link directly. Background taps open the
  // notifications tab to avoid role-switch races.
  final useNotificationsTab = !wasInForeground;
  final targetRoute = useNotificationsTab ? _notificationsTabRoute : route;
  final targetRole = useNotificationsTab ? null : role;

  // Skip live foreground taps that arrived without a route — nothing to
  // navigate to. (Background/terminated taps are routed to the
  // notifications tab regardless, so an empty route is fine there.)
  if (!useNotificationsTab && route.isEmpty) return;

  debugPrint('[Notif] live tap route=$route role=$role mid=$messageId '
      'wasFG=$wasInForeground → $targetRoute');

  _routeOrSwitch(state, route: targetRoute, role: targetRole);
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
            getIt<DeepLinkService>().setPendingRoute(route);
          }
        }
      });
      return;
    }
  } else {
    debugPrint('[Notif] _routeOrSwitch route=$route role=null');
  }
  getIt<DeepLinkService>().setPendingRoute(route);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorage.init();

  ApiConfig.environment = ProfileStorage.loadEnvironment();

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
    final route = _parseDeepLinkUri(uri);
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
    final route = initialMessage.data['route']?.toString();
    final role = initialMessage.data['role']?.toString();
    if (route != null && route.isNotEmpty) {
      _handleNotificationTap(
        route: route,
        role: role,
        messageId: initialMessage.messageId,
        wasInForeground: false,
      );
    }
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
