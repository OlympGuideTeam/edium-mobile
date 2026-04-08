import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/profile/profile_screen.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/student_quiz_library_screen.dart';
import 'package:edium/presentation/teacher/classes/classes_screen.dart';
import 'package:edium/presentation/shared/widgets/edium_tab_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
            getQuizzes: getIt(),
            likeQuiz: getIt(),
            getMySessions: getIt(),
          )..add(const LoadStudentQuizzesEvent()),
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
                              AppColors.secondary,
                              Color(0xFFFF8F5E),
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
                              'Привет, $firstName 🎓',
                              style: AppTextStyles.heading2
                                  .copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Готов проверить свои знания?',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // CTA
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => onNavigateToTab(1),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.rocket_launch_outlined,
                                    color: AppColors.primary, size: 24),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Начните обучение',
                                      style: AppTextStyles.bodySmall.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Перейдите в «Квизы», чтобы найти тест',
                                      style: AppTextStyles.caption,
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

