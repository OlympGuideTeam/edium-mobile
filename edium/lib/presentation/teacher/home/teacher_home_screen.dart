import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/debug/debug_panel_screen.dart';
import 'package:edium/presentation/teacher/classes/classes_screen.dart';
import 'package:edium/presentation/teacher/courses/courses_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_bloc.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_event.dart';
import 'package:edium/presentation/teacher/quiz_library/quiz_library_screen.dart';
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
      const CoursesScreen(),
      const ClassesScreen(),
    ];

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => QuizLibraryBloc(
            getQuizzes: getIt(),
            likeQuiz: getIt(),
          )..add(const LoadQuizzesEvent()),
        ),
        BlocProvider(
          create: (_) => CreateQuizBloc(getIt()),
        ),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (i) => setState(() => _currentIndex = i),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Главная',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_outlined),
                activeIcon: Icon(Icons.library_books),
                label: 'Библиотека',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school_outlined),
                activeIcon: Icon(Icons.school),
                label: 'Курсы',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined),
                activeIcon: Icon(Icons.groups),
                label: 'Классы',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeacherDashboardPage extends StatelessWidget {
  final void Function(int) onNavigateToTab;

  const _TeacherDashboardPage({required this.onNavigateToTab});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final name = state is AuthAuthenticated ? state.user.name : '';
          final firstName =
              name.isNotEmpty ? name.split(' ').first : 'Преподаватель';
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                      child: Row(
                        children: [
                          Text(
                            'Edium',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Spacer(),
                          _ProfileButton(
                            name: firstName,
                            role: 'Преподаватель',
                            onSwitchMode: () =>
                                context.go('/student/home'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Greeting card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primary,
                              Color(0xFF7C6CF9),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Привет, $firstName 👋',
                              style: AppTextStyles.heading2
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Чему сегодня обучим?',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Quick actions
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        'Быстрые действия',
                        style: AppTextStyles.subtitle,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _QuickActionTile(
                            icon: Icons.add_circle_outline,
                            label: 'Создать новый квиз',
                            subtitle: 'Добавьте вопросы и запустите тест',
                            color: AppColors.primary,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) => CreateQuizBloc(getIt()),
                                  child: const CreateQuizScreen(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _QuickActionTile(
                            icon: Icons.library_books_outlined,
                            label: 'Библиотека квизов',
                            subtitle:
                                'Просматривайте и управляйте квизами',
                            color: AppColors.secondary,
                            onTap: () => onNavigateToTab(1),
                          ),
                          const SizedBox(height: 12),
                          _QuickActionTile(
                            icon: Icons.school_outlined,
                            label: 'Курсы',
                            subtitle: 'Создавайте курсы из набора квизов',
                            color: AppColors.success,
                            onTap: () => onNavigateToTab(2),
                          ),
                          const SizedBox(height: 12),
                          _QuickActionTile(
                            icon: Icons.groups_outlined,
                            label: 'Классы',
                            subtitle: 'Управляйте группами студентов',
                            color: const Color(0xFFEC4899),
                            onTap: () => onNavigateToTab(3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
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

// ── Profile button (opens bottom sheet) ─────────────────────────────────────

class _ProfileButton extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback onSwitchMode;

  const _ProfileButton({
    required this.name,
    required this.role,
    required this.onSwitchMode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showProfileSheet(context),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : 'U',
            style: AppTextStyles.subtitle
                .copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: AppTextStyles.heading2
                        .copyWith(color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(name, style: AppTextStyles.subtitle),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  role,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Switch mode
              _SheetAction(
                icon: Icons.swap_horiz_outlined,
                label: 'Режим студента',
                onTap: () {
                  Navigator.pop(context);
                  onSwitchMode();
                },
              ),
              const SizedBox(height: 4),
              // Debug
              _SheetAction(
                icon: Icons.bug_report_outlined,
                label: 'Отладка (Hive)',
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const DebugPanelScreen()),
                  );
                },
              ),
              const SizedBox(height: 4),
              // Logout
              _SheetAction(
                icon: Icons.logout_outlined,
                label: 'Выйти',
                color: AppColors.error,
                onTap: () {
                  Navigator.pop(context);
                  getIt<AuthBloc>().add(const LogoutEvent());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: c, size: 22),
      title: Text(label, style: AppTextStyles.bodySmall.copyWith(color: c)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

// ── Quick action tile ────────────────────────────────────────────────────────

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.bodySmall
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
