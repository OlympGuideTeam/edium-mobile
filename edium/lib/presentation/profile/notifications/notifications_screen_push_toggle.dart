part of 'notifications_screen.dart';

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

