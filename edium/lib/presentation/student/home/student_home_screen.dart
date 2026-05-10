import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/student_dashboard.dart';
import 'package:edium/domain/repositories/live_repository.dart' show ILiveRepository;
import 'package:edium/domain/entities/user.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/live/live_session_completed_navigation.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:edium/presentation/profile/profile_screen.dart';
import 'package:edium/presentation/student/home/bloc/notification_badge_cubit.dart';
import 'package:edium/presentation/student/home/bloc/student_dashboard_cubit.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_bloc.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/student_quiz_library_screen.dart';
import 'package:edium/presentation/teacher/classes/classes_screen.dart';
import 'package:edium/presentation/shared/widgets/edium_tab_bar.dart';
import 'package:edium/presentation/shared/widgets/edium_refresh_indicator.dart';
import 'package:edium/presentation/shared/widgets/notification_bell_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'student_home_screen_student_dashboard_page.dart';
part 'student_home_screen_dashboard_section.dart';
part 'student_home_screen_recent_grades_block.dart';
part 'student_home_screen_grade_row.dart';
part 'student_home_screen_active_test_tile.dart';
part 'student_home_screen_active_live_banner.dart';



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
        BlocProvider(
          create: (_) => NotificationBadgeCubit(getIt(), getIt())..load(),
        ),
      ],

      child: Builder(
        builder: (context) => Scaffold(
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
          onTap: (i) {
            setState(() => _currentIndex = i);
            if (i == 0) {
              context.read<NotificationBadgeCubit>().load();
            }
          },
          items: [
            const EdiumTabItem(
              icon: CupertinoIcons.house,
              activeIcon: CupertinoIcons.house_fill,
              label: 'Главная',
            ),
            const EdiumTabItem(
              icon: CupertinoIcons.compass,
              activeIcon: CupertinoIcons.compass_fill,
              label: 'Квизы',
            ),
            const EdiumTabItem(
              icon: CupertinoIcons.person_2,
              activeIcon: CupertinoIcons.person_2_fill,
              label: 'Классы',
            ),
            EdiumTabItem(
              icon: CupertinoIcons.person_crop_circle,
              activeIcon: CupertinoIcons.person_crop_circle_fill,
              label: 'Профиль',
              onDoubleTap: () {
                final authState = context.read<AuthBloc>().state;
                if (authState is! AuthAuthenticated) return;
                final r = authState.user.role;
                if (r == null) return;
                final next = r == UserRole.teacher ? 'student' : 'teacher';
                context.read<AuthBloc>().add(SwitchToRoleEvent(next));
              },
            ),
          ],
        ),
        ),
      ),
    );
  }
}

