part of 'profile_screen.dart';

class _ProfileContent extends StatelessWidget {
  final User user;
  final UserStatistic statistic;

  const _ProfileContent({required this.user, required this.statistic});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isTeacher = location.startsWith('/teacher');
    final roleLabel = isTeacher ? 'Учитель' : 'Ученик';

    return SafeArea(
      child: EdiumRefreshIndicator(
        onRefresh: () async {
          final bloc = context.read<ProfileBloc>();
          bloc.add(const LoadProfileEvent());
          await bloc.stream.firstWhere(
              (s) => s is ProfileLoaded || s is ProfileError);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.mono900,
                    borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                  ),
                  child: Text(roleLabel.toUpperCase(),
                      style: AppTextStyles.badgeText),
                ),
                const SizedBox(height: 12),
                Text(
                  [user.surname, user.name]
                      .whereType<String>()
                      .where((s) => s.isNotEmpty)
                      .join(' '),
                  style: AppTextStyles.screenTitle,
                ),
                const SizedBox(height: 32),

                isTeacher
                    ? _TeacherStats(statistic: statistic)
                    : _StudentStats(statistic: statistic),
                const SizedBox(height: 24),

                _ActionTile(
                  icon: Icons.edit_outlined,
                  label: 'Редактировать профиль',
                  onTap: () async {
                    final result =
                        await context.push('/profile/edit', extra: user);
                    if (result == true && context.mounted) {
                      context.read<ProfileBloc>().add(const LoadProfileEvent());
                    }
                  },
                ),
                const SizedBox(height: 8),
                _ActionTile(
                  icon: Icons.notifications_outlined,
                  label: 'Уведомления',
                  onTap: () => context.push('/profile/notifications'),
                ),
                const SizedBox(height: 8),
                _ActionTile(
                  icon: Icons.swap_horiz_outlined,
                  label: isTeacher
                      ? 'Переключиться на ученика'
                      : 'Переключиться на учителя',
                  onTap: () {
                    getIt<AuthBloc>().add(
                      SwitchToRoleEvent(isTeacher ? 'student' : 'teacher'),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

