part of 'notifications_screen.dart';

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
                  final route = item.role != null
                      ? _withRole(item.route!, item.role!)
                      : item.route!;
                  context.push(route);
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

