part of 'student_home_screen.dart';

class _StudentDashboardPage extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const _StudentDashboardPage({required this.onNavigateToTab});

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([
      context.read<StudentDashboardCubit>().load(),
      context.read<NotificationBadgeCubit>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          final user =
              authState is AuthAuthenticated ? authState.user : null;
          final firstName = (user?.name.isNotEmpty == true)
              ? user!.name.split(' ').first
              : 'Студент';
          return Scaffold(
            backgroundColor: Colors.white,
            body: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.translucent,
              child: SafeArea(
                child: EdiumRefreshIndicator(
                  onRefresh: () => _refresh(context),
                  child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.screenPaddingH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.mono900,
                            borderRadius:
                                BorderRadius.circular(AppDimens.radiusXs),
                          ),
                          child: const Text('УЧЕНИК',
                              style: AppTextStyles.badgeText),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<NotificationBadgeCubit, int>(
                          builder: (context, unreadCount) => Row(
                            children: [
                              const Text('Edium',
                                  style: AppTextStyles.screenTitle),
                              const Spacer(),
                              NotificationBellButton(
                                unreadCount: unreadCount,
                                onTap: () async {
                                  await context
                                      .push('/profile/notifications');
                                  if (context.mounted) {
                                    context
                                        .read<NotificationBadgeCubit>()
                                        .load();
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Привет, $firstName',
                          style: AppTextStyles.screenTitle,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Готов проверить свои знания?',
                          style: AppTextStyles.screenSubtitle,
                        ),
                        const SizedBox(height: 16),
                        const _JoinLiveBlock(),
                        const SizedBox(height: 16),
                        BlocBuilder<StudentDashboardCubit,
                            StudentDashboardState>(
                          builder: (context, state) {
                            final meta = state is StudentDashboardLoaded
                                ? state.activeLive
                                : null;
                            return AnimatedSwitcher(
                              duration: _kBannerAnimDuration,
                              switchInCurve: Curves.easeOut,
                              switchOutCurve: Curves.easeIn,
                              transitionBuilder: (child, animation) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, -0.08),
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child: meta != null
                                  ? Padding(
                                      key: ValueKey(meta.sessionId),
                                      padding:
                                          const EdgeInsets.only(bottom: 24),
                                      child: _ActiveLiveBanner(meta: meta),
                                    )
                                  : const SizedBox.shrink(
                                      key: ValueKey('no_live'),
                                    ),
                            );
                          },
                        ),
                        _DashboardSection(
                            onNavigateToTab: onNavigateToTab),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}

