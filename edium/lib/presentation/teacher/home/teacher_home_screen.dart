import 'package:edium/core/di/injection.dart';
import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:edium/domain/entities/awaiting_review_session.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
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

part 'teacher_home_screen_teacher_dashboard_page.dart';
part 'teacher_home_screen_awaiting_review_section.dart';
part 'teacher_home_screen_awaiting_review_card.dart';
part 'teacher_home_screen_status_chip.dart';
part 'teacher_home_screen_quick_action_tile.dart';


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
          create: (_) => NotificationBadgeCubit(getIt(), getIt())..load(),
        ),
      ],

      child: Builder(
        builder: (context) => Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
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
              icon: CupertinoIcons.book,
              activeIcon: CupertinoIcons.book_fill,
              label: 'Библиотека',
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

