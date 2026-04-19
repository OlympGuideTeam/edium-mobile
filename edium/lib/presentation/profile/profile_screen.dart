import 'package:edium/core/di/injection.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/entities/user_statistic.dart';
import 'package:edium/presentation/profile/bloc/profile_bloc.dart';
import 'package:edium/presentation/profile/bloc/profile_event.dart';
import 'package:edium/presentation/profile/bloc/profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileBloc(
        getMe: getIt(),
        getStatistic: getIt(),
      )..add(const LoadProfileEvent()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.mono900,
                strokeWidth: 2,
              ),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 15, color: AppColors.mono400),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => context
                        .read<ProfileBloc>()
                        .add(const LoadProfileEvent()),
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
          final loaded = state as ProfileLoaded;
          return _ProfileContent(
            user: loaded.user,
            statistic: loaded.statistic,
          );
        },
      ),
    );
  }
}

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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            // Тег
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.mono900,
                borderRadius: BorderRadius.circular(AppDimens.radiusXs),
              ),
              child: Text(roleLabel.toUpperCase(), style: AppTextStyles.badgeText),
            ),
            const SizedBox(height: 12),
            Text(
              [user.surname, user.name].whereType<String>().where((s) => s.isNotEmpty).join(' '),
              style: AppTextStyles.screenTitle,
            ),
            const SizedBox(height: 32),
            // Статистика
            isTeacher
                ? _TeacherStats(statistic: statistic)
                : _StudentStats(statistic: statistic),
            const SizedBox(height: 24),
            // Действия
            _ActionTile(
              icon: Icons.edit_outlined,
              label: 'Редактировать профиль',
              onTap: () async {
                final result = await context.push('/profile/edit', extra: user);
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
                final storage = getIt<ProfileStorage>();
                if (isTeacher) {
                  storage.saveRole('student');
                  context.go('/student/home');
                } else {
                  storage.saveRole('teacher');
                  context.go('/teacher/home');
                }
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Статистика учителя ──────────────────────────────────────────────────────

class _TeacherStats extends StatelessWidget {
  final UserStatistic statistic;

  const _TeacherStats({required this.statistic});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: statistic.classTeacherCount.toString(),
            label: 'Классов',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: statistic.quizCountCreated.toString(),
            label: 'Квизов',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: statistic.studentCount.toString(),
            label: 'Учеников',
          ),
        ),
      ],
    );
  }
}

// ── Статистика ученика ──────────────────────────────────────────────────────

class _StudentStats extends StatelessWidget {
  final UserStatistic statistic;

  const _StudentStats({required this.statistic});

  @override
  Widget build(BuildContext context) {
    final score = statistic.avgQuizScore;
    final scoreStr = score == score.roundToDouble()
        ? score.toInt().toString()
        : score.toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: statistic.courseStudentCount.toString(),
            label: 'Классов',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: statistic.quizCountPassed.toString(),
            label: 'Квизов',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: scoreStr,
            label: 'Ср. оценка',
          ),
        ),
      ],
    );
  }
}

// ── Карточка статистики ─────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        border: Border.all(color: AppColors.mono150, width: AppDimens.borderWidth),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.mono900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.mono350),
          ),
        ],
      ),
    );
  }
}

// ── Кнопка-действие ─────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
                color: AppColors.mono150, width: AppDimens.borderWidth),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.mono900, size: 20),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.fieldText.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.mono250, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
