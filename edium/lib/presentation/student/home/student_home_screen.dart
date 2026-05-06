import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/student_dashboard.dart';
import 'package:edium/domain/repositories/live_repository.dart' show ILiveRepository;
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/profile/profile_screen.dart';
import 'package:edium/presentation/student/home/bloc/student_dashboard_cubit.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/student_quiz_library_screen.dart';
import 'package:edium/presentation/teacher/classes/classes_screen.dart';
import 'package:edium/presentation/shared/widgets/edium_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Длительность анимации появления/скрытия баннера.
const _kBannerAnimDuration = Duration(milliseconds: 350);

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  int _currentIndex = 0;

  void _goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => StudentQuizBloc(
            getPublicQuizzes: getIt(),
          )..add(const LoadStudentQuizzesEvent()),
        ),
        BlocProvider(
          create: (_) => StudentDashboardCubit(
            getIt(),
            getIt(),
            getIt(),
            getIt(),
          )..load(),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            _StudentDashboardPage(onNavigateToTab: _goToTab),
            const StudentQuizLibraryScreen(),
            const ClassesScreen(role: 'student'),
            const ProfileScreen(),
          ],
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
              icon: CupertinoIcons.compass,
              activeIcon: CupertinoIcons.compass_fill,
              label: 'Квизы',
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

class _StudentDashboardPage extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const _StudentDashboardPage({required this.onNavigateToTab});

  Future<void> _refresh(BuildContext context) async {
    await context.read<StudentDashboardCubit>().load();
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
            body: SafeArea(
              child: RefreshIndicator(
                color: AppColors.mono900,
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
                        const Text('Edium', style: AppTextStyles.screenTitle),
                        const SizedBox(height: 24),
                        Text(
                          'Привет, $firstName',
                          style: AppTextStyles.screenTitle,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Готов проверить свои знания?',
                          style: AppTextStyles.screenSubtitle,
                        ),
                        const SizedBox(height: 24),
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
          );
        },
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const _DashboardSection({required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentDashboardCubit, StudentDashboardState>(
      builder: (context, state) {
        final dashboard =
            state is StudentDashboardLoaded ? state.dashboard : null;
        final hasActiveTests =
            dashboard != null && dashboard.activeTests.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dashboard != null && dashboard.recentGrades.isNotEmpty) ...[
              const Text('ПОСЛЕДНИЕ ОЦЕНКИ',
                  style: AppTextStyles.sectionTag),
              const SizedBox(height: 12),
              _RecentGradesBlock(items: dashboard.recentGrades),
              const SizedBox(height: 24),
            ],
            if (hasActiveTests) ...[
              const Text('ДОСТУПНЫЕ ТЕСТЫ',
                  style: AppTextStyles.sectionTag),
              const SizedBox(height: 12),
              ...dashboard.activeTests.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ActiveTestTile(item: item),
                  )),
              const SizedBox(height: 24),
            ],
            Material(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AppDimens.radiusLg),
              child: InkWell(
                onTap: () => onNavigateToTab(1),
                borderRadius:
                    BorderRadius.circular(AppDimens.radiusLg),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppDimens.radiusLg),
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
                          borderRadius: BorderRadius.circular(
                              AppDimens.radiusMd),
                        ),
                        child: Icon(CupertinoIcons.compass,
                            color: AppColors.mono700, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Начните обучение',
                              style:
                                  AppTextStyles.fieldText.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Перейдите в «Квизы», чтобы найти тест',
                              style: AppTextStyles.helperText,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: AppColors.mono300, size: 20),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _RecentGradesBlock extends StatelessWidget {
  final List<RecentGradeItem> items;

  const _RecentGradesBlock({required this.items});

  @override
  Widget build(BuildContext context) {
    final scored = items.where((e) => e.score != null).toList();
    final avg = scored.isEmpty
        ? null
        : scored.fold(0.0, (sum, e) => sum + e.score!) / scored.length;

    return Container(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Expanded(
                child: Text(
                  'Среднее',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.mono400,
                  ),
                ),
              ),
              Text(
                avg != null ? avg.toStringAsFixed(1) : '—',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.mono100),
          const SizedBox(height: 12),
          ...items.map((item) => _GradeRow(item: item)),
        ],
      ),
    );
  }
}

class _GradeRow extends StatelessWidget {
  final RecentGradeItem item;

  const _GradeRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.quizTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.mono700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _scoreText,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  item.score != null ? FontWeight.w700 : FontWeight.w400,
              color: item.score != null
                  ? AppColors.mono900
                  : AppColors.mono400,
            ),
          ),
        ],
      ),
    );
  }

  String get _scoreText {
    if (item.score != null) return item.score!.toStringAsFixed(1);
    return switch (item.status) {
      'grading' => 'Проверяется',
      'graded' => 'Будет позже',
      _ => '—',
    };
  }
}

class _ActiveTestTile extends StatelessWidget {
  final ActiveTestItem item;

  static final _dateFmt = DateFormat('d MMM', 'ru');

  const _ActiveTestTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: () => context.push(
          '/test/${item.sessionId}',
          extra: {'quizTitle': item.quizTitle},
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
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.quizTitle,
                      style: AppTextStyles.fieldText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitle,
                      style: AppTextStyles.helperText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: AppColors.mono300, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  String get _subtitle {
    if (item.attemptStatus == 'in_progress') return 'В процессе';
    if (item.sessionFinishedAt != null) {
      return 'Дедлайн: ${_dateFmt.format(item.sessionFinishedAt!.toLocal())}';
    }
    return 'Доступен';
  }
}

class _ActiveLiveBanner extends StatelessWidget {
  final LiveSessionMeta meta;

  const _ActiveLiveBanner({required this.meta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0x1FFFFFFF),
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: const Icon(
                  CupertinoIcons.bolt_fill,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.quizTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0x80FFFFFF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              child: InkWell(
                onTap: () => _joinLive(context),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Войти',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono900,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _subtitle {
    final parts = <String>['Идёт сейчас'];
    if (meta.questionCount > 0) {
      parts.add('${meta.questionCount} вопр.');
    }
    return parts.join(' · ');
  }

  Future<void> _joinLive(BuildContext context) async {
    final repo = getIt<ILiveRepository>();
    final nav = Navigator.of(context, rootNavigator: true);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final join = await repo.joinLiveSession(sessionId: meta.sessionId);
      nav.pop();
      router.push(
        '/live/${meta.sessionId}/student',
        extra: {
          'attemptId': join.attemptId,
          'wsToken': join.wsToken,
          'quizTitle': meta.quizTitle,
          'questionCount': meta.questionCount,
          'moduleId': join.moduleId ?? meta.moduleId ?? '',
        },
      );
    } catch (e) {
      nav.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('Ошибка входа: $e')),
      );
    }
  }
}
