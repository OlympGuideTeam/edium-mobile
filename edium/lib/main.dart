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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final ValueNotifier<int> appRestartKey = ValueNotifier(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorage.init();

  ApiConfig.environment = ProfileStorage.loadEnvironment();

  NotificationService? notificationService;
  DeepLinkService deepLinkService = DeepLinkService();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    notificationService = NotificationService();
    await notificationService.initialize();

    final initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    final initialRoute = initialMessage?.data['route'] as String?;
    if (initialRoute != null && initialRoute.isNotEmpty) {
      deepLinkService.setPendingRoute(initialRoute);
    }
  } catch (e) {
    debugPrint('Firebase init failed: $e');
  }

  await initializeDependencies(
    notificationService: notificationService ?? NotificationService(),
    deepLinkService: deepLinkService,
  );

  getIt<AuthBloc>().add(const AppStarted());

  if (notificationService != null) {
    // Use push (not go) so the user can navigate back from the opened screen
    notificationService.tapRoute.addListener(() {
      final route = notificationService!.tapRoute.value;
      if (route != null) {
        pushRouteFromNotification(route);
      }
    });
  }

  runApp(
    ValueListenableBuilder<int>(
      valueListenable: appRestartKey,
      builder: (_, key, __) => EdiumApp(key: ValueKey(key)),
    ),
  );
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
      ),
    );
  }
}
