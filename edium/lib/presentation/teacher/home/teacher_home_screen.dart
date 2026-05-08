import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/awaiting_review_session.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/profile/profile_screen.dart';
import 'package:edium/presentation/teacher/classes/classes_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:edium/presentation/teacher/home/bloc/awaiting_review_cubit.dart';
import 'package:edium/presentation/teacher/quiz_library/quiz_library_screen.dart';
import 'package:edium/presentation/shared/widgets/edium_tab_bar.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/notification_bell_button.dart';
import 'package:edium/presentation/student/home/bloc/notification_badge_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  int _currentIndex = 0;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      _TeacherDashboardPage(onNavigateToTab: _goToTab),
      const QuizLibraryScreen(),
      const ClassesScreen(role: 'teacher'),
      const ProfileScreen(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => CreateQuizBloc(
                getIt(),
                getIt<CreateSessionUsecase>(),
                getIt<IQuizRepository>(),
              ),
        ),
        BlocProvider(
          create: (_) => AwaitingReviewCubit(getIt())..load(),
        ),
        BlocProvider(
          create: (_) => NotificationBadgeCubit(getIt())..load(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: EdiumTabBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            EdiumTabItem(
              icon: CupertinoIcons.house,
              activeIcon: CupertinoIcons.house_fill,
              label: 'Главная',
            ),
            EdiumTabItem(
              icon: CupertinoIcons.book,
              activeIcon: CupertinoIcons.book_fill,
              label: 'Библиотека',
            ),
            EdiumTabItem(
              icon: CupertinoIcons.person_2,
              activeIcon: CupertinoIcons.person_2_fill,
              label: 'Классы',
            ),
            EdiumTabItem(
              icon: CupertinoIcons.person_crop_circle,
              activeIcon: CupertinoIcons.person_crop_circle_fill,
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}

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
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
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
                                onTap: () =>
                                    context.push('/profile/notifications'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _AwaitingReviewSection(),
                        const SizedBox(height: 24),
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

class _AwaitingReviewSection extends StatelessWidget {
  const _AwaitingReviewSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AwaitingReviewCubit, AwaitingReviewState>(
      builder: (context, state) {
        if (state is AwaitingReviewLoaded && state.sessions.isNotEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ОЖИДАЮТ ПРОВЕРКИ', style: AppTextStyles.sectionTag),
              const SizedBox(height: 12),
              ...state.sessions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _AwaitingReviewCard(session: s),
                  )),
              const SizedBox(height: 14),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _AwaitingReviewCard extends StatelessWidget {
  final AwaitingReviewSession session;

  const _AwaitingReviewCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final total = session.gradingCount + session.gradedCount + session.completedCount;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: () => context.push(
          '/teacher/review/${session.sessionId}',
          extra: {'quizTitle': session.quizTitle},
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.quizTitle,
                style: AppTextStyles.fieldText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatusChip(
                    label: 'к проверке',
                    count: session.gradedCount,
                    active: session.gradedCount > 0,
                  ),
                  const SizedBox(width: 6),
                  _StatusChip(
                    label: 'у ИИ',
                    count: session.gradingCount,
                    active: false,
                  ),
                  const SizedBox(width: 6),
                  _StatusChip(
                    label: 'готово',
                    count: session.completedCount,
                    active: false,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: total > 0 ? session.completedCount / total : 0,
                  minHeight: 3,
                  backgroundColor: AppColors.mono100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.mono700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool active;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.mono900 : AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        '$count $label',
        style: AppTextStyles.helperText.copyWith(
          color: active ? Colors.white : AppColors.mono400,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mono50,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Icon(icon, color: AppColors.mono700, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.fieldText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.helperText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.mono300, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
