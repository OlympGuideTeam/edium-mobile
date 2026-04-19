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

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.mono900),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/teacher/home');
            }
          },
        ),
        title: const Text('Уведомления', style: AppTextStyles.screenTitle),
        centerTitle: false,
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listenWhen: (_, current) =>
            current is NotificationsLoaded && current.shouldOpenSettings,
        listener: (_, __) => _openAppSettings(),
        builder: (context, state) {
          if (state is NotificationsLoading || state is NotificationsInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.mono900,
                strokeWidth: 2,
              ),
            );
          }

          if (state is NotificationsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(
                        fontSize: 15, color: AppColors.mono400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context
                        .read<NotificationsBloc>()
                        .add(const LoadNotificationsEvent()),
                    child: const Text(
                      'Повторить',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono900,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final loaded = state as NotificationsLoaded;
          return _NotificationsContent(state: loaded);
        },
      ),
    );
  }

  Future<void> _openAppSettings() async {
    final uri = Platform.isIOS
        ? Uri.parse('app-settings:')
        : Uri.parse('package:online.edium.app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}

class _NotificationsContent extends StatelessWidget {
  final NotificationsLoaded state;

  const _NotificationsContent({required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
      children: [
        const SizedBox(height: 24),
        _PushToggle(enabled: state.pushEnabled),
        const SizedBox(height: 32),
        if (state.items.isNotEmpty) ...[
          Text('ВХОДЯЩИЕ', style: AppTextStyles.sectionTag),
          const SizedBox(height: 12),
          ...state.items.map(
            (item) => _NotificationTile(
              item: item,
              onTap: () {
                if (!item.isRead) {
                  context
                      .read<NotificationsBloc>()
                      .add(MarkReadEvent(item.id));
                }
                if (item.route != null) {
                  context.push(item.route!);
                }
              },
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 48),
            child: Center(
              child: Text(
                'Уведомлений пока нет',
                style: AppTextStyles.screenSubtitle,
              ),
            ),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _PushToggle extends StatelessWidget {
  final bool enabled;

  const _PushToggle({required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(
            color: AppColors.mono150, width: AppDimens.borderWidth),
      ),
      child: Row(
        children: [
          const Icon(Icons.notifications_outlined,
              color: AppColors.mono900, size: 20),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Push-уведомления',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.mono900,
              ),
            ),
          ),
          CupertinoSwitch(
            value: enabled,
            activeTrackColor: AppColors.mono900,
            onChanged: (val) => context
                .read<NotificationsBloc>()
                .add(TogglePushEvent(val)),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: item.route != null ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: item.isRead ? AppColors.mono150 : AppColors.mono400,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!item.isRead)
                Container(
                  margin: const EdgeInsets.only(top: 5, right: 10),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.mono900,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.isRead
                            ? FontWeight.w400
                            : FontWeight.w600,
                        color: AppColors.mono900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.body,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.mono400),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _formatDate(item.createdAt),
                style: const TextStyle(fontSize: 11, color: AppColors.mono300),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин';
    if (diff.inHours < 24) return '${diff.inHours} ч';
    const months = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }
}
