import 'package:edium/core/di/injection.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ошибка загрузки', style: AppTextStyles.body),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => context
                        .read<ProfileBloc>()
                        .add(const LoadProfileEvent()),
                    child: const Text('Повторить'),
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
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Инициалы
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isTeacher ? AppColors.primaryLight : AppColors.secondaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials(user.name),
                  style: AppTextStyles.heading1.copyWith(
                    color: isTeacher ? AppColors.primary : AppColors.secondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Имя Фамилия
            Text(
              user.name,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            // Роль
            Text(
              '$roleLabel  ·  edium',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            // Телефон
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                _maskPhone(user.phone),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Статистика
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: isTeacher
                  ? _TeacherStats(statistic: statistic)
                  : _StudentStats(statistic: statistic),
            ),
            const SizedBox(height: 24),
            // Действия
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _ActionTile(
                    icon: Icons.edit_outlined,
                    label: 'Редактировать профиль',
                    onTap: () async {
                      final result = await context.push(
                        '/profile/edit',
                        extra: user,
                      );
                      if (result == true && context.mounted) {
                        context
                            .read<ProfileBloc>()
                            .add(const LoadProfileEvent());
                      }
                    },
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
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  String _maskPhone(String phone) {
    // +79991234567 → +7 999 ···–···–67
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 11) return phone;
    final code = digits.substring(1, 4);
    final last = digits.substring(digits.length - 2);
    return '+7  $code  ···–···–$last';
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
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: statistic.quizCountCreated.toString(),
            label: 'Квизов',
          ),
        ),
        const SizedBox(width: 12),
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
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: statistic.quizCountPassed.toString(),
            label: 'Квизов',
          ),
        ),
        const SizedBox(width: 12),
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
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
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
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
