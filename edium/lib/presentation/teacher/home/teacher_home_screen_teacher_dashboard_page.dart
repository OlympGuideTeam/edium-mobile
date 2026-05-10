part of 'teacher_home_screen.dart';

class _TeacherDashboardPage extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const _TeacherDashboardPage({required this.onNavigateToTab});

  Future<void> _refresh(BuildContext context) async {
    await Future.wait([
      context.read<AwaitingReviewCubit>().load(),
      context.read<NotificationBadgeCubit>().load(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final user =
              state is AuthAuthenticated ? state.user : null;
          final firstName = (user?.name.isNotEmpty == true)
              ? user!.name.split(' ').first
              : 'Учитель';
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: EdiumRefreshIndicator(
                onRefresh: () => _refresh(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppDimens.screenPaddingH,
                    0,
                    AppDimens.screenPaddingH,
                    96,
                  ),
                  children: [
                    Column(
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
                          child: const Text('УЧИТЕЛЬ',
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
                          'Ведите классы, запускайте квизы и проверяйте работы.',
                          style: AppTextStyles.screenSubtitle,
                        ),
                        const SizedBox(height: 16),
                        const _AwaitingReviewSection(),
                        const Text('БЫСТРЫЕ ДЕЙСТВИЯ',
                            style: AppTextStyles.sectionTag),
                        const SizedBox(height: 16),
                        _QuickActionTile(
                          icon: CupertinoIcons.add,
                          label: 'Создать новый квиз',
                          subtitle: 'Добавьте вопросы и запустите тест',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BlocProvider(
                                create: (_) => CreateQuizBloc(
                                  getIt(),
                                  getIt<CreateSessionUsecase>(),
                                  getIt<IQuizRepository>(),
                                ),
                                child: const CreateQuizScreen(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _QuickActionTile(
                          icon: CupertinoIcons.book,
                          label: 'Библиотека квизов',
                          subtitle: 'Просматривайте и управляйте квизами',
                          onTap: () => onNavigateToTab(1),
                        ),
                        const SizedBox(height: 10),
                        _QuickActionTile(
                          icon: CupertinoIcons.person_2,
                          label: 'Классы',
                          subtitle: 'Управляйте группами студентов',
                          onTap: () => onNavigateToTab(2),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

