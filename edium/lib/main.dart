import 'package:edium/core/config/api_config.dart';
import 'package:edium/core/di/injection.dart';
import 'package:edium/core/router/app_router.dart';
import 'package:edium/core/storage/hive_storage.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_theme.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

final ValueNotifier<int> appRestartKey = ValueNotifier(0);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveStorage.init();

  ApiConfig.environment = ProfileStorage.loadEnvironment();

  await initializeDependencies();
  getIt<AuthBloc>().add(const AppStarted());

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
