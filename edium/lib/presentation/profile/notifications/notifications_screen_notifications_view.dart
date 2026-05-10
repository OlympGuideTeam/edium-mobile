part of 'notifications_screen.dart';

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

