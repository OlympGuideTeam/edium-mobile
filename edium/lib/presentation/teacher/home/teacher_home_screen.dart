import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/profile/profile_screen.dart';
import 'package:edium/presentation/teacher/classes/classes_screen.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/create_quiz_screen.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_bloc.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_event.dart';
import 'package:edium/presentation/teacher/quiz_library/quiz_library_screen.dart';
import 'package:edium/presentation/shared/widgets/edium_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Text(
                        'Edium',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
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
                            icon: Icons.groups_outlined,
                            label: 'Классы',
                            subtitle: 'Управляйте группами студентов',
                            color: AppColors.success,
                            onTap: () => onNavigateToTab(2),
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
