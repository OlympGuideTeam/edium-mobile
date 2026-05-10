import 'dart:io';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/profile/notifications/bloc/notifications_bloc.dart';
import 'package:edium/presentation/profile/notifications/bloc/notifications_event.dart';
import 'package:edium/presentation/profile/notifications/bloc/notifications_state.dart';
import 'package:edium/services/herald_api_service/herald_dto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

part 'notifications_screen_notifications_view.dart';
part 'notifications_screen_notifications_content.dart';
part 'notifications_screen_push_toggle.dart';
part 'notifications_screen_notification_tile.dart';


class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationsBloc(
        heraldApiService: getIt(),
        notificationService: getIt(),
      )..add(const LoadNotificationsEvent()),
      child: const _NotificationsView(),
    );
  }
}

