import 'package:app_links/app_links.dart';
import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/core/router/app_router.dart' show buildRouter, pushRouteFromNotification;
import 'package:edium/core/storage/hive_storage.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_theme.dart';
import 'package:edium/firebase_options.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/services/notification_service/deep_link_service.dart';
import 'package:edium/services/notification_service/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

final ValueNotifier<int> appRestartKey = ValueNotifier(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorage.init();

  ApiConfig.environment = ProfileStorage.loadEnvironment();

  NotificationService? notificationService;
  final deepLinkService = DeepLinkService();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    notificationService = NotificationService();
    await notificationService.initialize();

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    final initialRoute = initialMessage?.data['route'] as String?;
    if (initialRoute != null && initialRoute.isNotEmpty) {
      deepLinkService.setPendingRoute(initialRoute);
    }
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

  getIt<AuthBloc>().add(const AppStarted());

  // Listen for links while app is running in foreground/background
  appLinks.uriLinkStream.listen((uri) {
    debugPrint('[DeepLink] uriLinkStream received: $uri');
    final route = _parseDeepLinkUri(uri);
    debugPrint('[DeepLink] parsed route: $route');
    if (route != null) getIt<DeepLinkService>().setPendingRoute(route);
  });

  if (notificationService != null) {
    // Use push (not go) so the user can navigate back from the opened screen
    notificationService.tapRoute.addListener(() {
      final route = notificationService!.tapRoute.value;
      if (route != null) pushRouteFromNotification(route);
    });
  }

  runApp(
    ValueListenableBuilder<int>(
      valueListenable: appRestartKey,
      builder: (_, key, __) => EdiumApp(key: ValueKey(key)),
    ),
  );
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
