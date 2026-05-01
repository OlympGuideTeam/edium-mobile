import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/auth/screens/name_input_screen.dart';
import 'package:edium/presentation/auth/screens/otp_screen.dart';
import 'package:edium/presentation/auth/screens/phone_input_screen.dart';
import 'package:edium/presentation/auth/screens/role_selection_screen.dart';
import 'package:edium/presentation/auth/screens/splash_screen.dart';
import 'package:edium/presentation/auth/screens/welcome_screen.dart';
import 'package:edium/presentation/class_detail/class_detail_screen.dart';
import 'package:edium/presentation/teacher/course_detail/course_detail_screen.dart';
import 'package:edium/presentation/teacher/create_course/create_course_screen.dart';
import 'package:edium/presentation/profile/edit_profile/edit_profile_screen.dart';
import 'package:edium/presentation/profile/notifications/notifications_screen.dart';
import 'package:edium/presentation/shared/test/attempt_review_screen.dart';
import 'package:edium/presentation/teacher/grade_attempt/teacher_grade_attempt_screen.dart';
import 'package:edium/presentation/shared/invite/invite_screen.dart';
import 'package:edium/presentation/student/home/student_home_screen.dart';
import 'package:edium/presentation/student/test/test_preview_screen.dart';
import 'package:edium/presentation/teacher/home/teacher_home_screen.dart';
import 'package:edium/presentation/teacher/test_monitoring/test_monitoring_screen.dart';
import 'package:edium/presentation/teacher/test_session/test_session_results_screen.dart';
import 'package:edium/services/notification_service/deep_link_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter? _routerInstance;

// Used by main.dart for live notification taps (push on top of current stack)
void pushRouteFromNotification(String route) {
  _routerInstance?.push(route);
}

class RouterNotifier extends ChangeNotifier {
  late final StreamSubscription _sub;

  RouterNotifier() {
    _sub = getIt<AuthBloc>().stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _routerNotifier = RouterNotifier();

GoRouter buildRouter() {
  _routerInstance = GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([
      _routerNotifier,
      getIt<DeepLinkService>(),
    ]),
    redirect: _redirect,
    routes: [
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (_, __) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/phone',
        builder: (_, __) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          final channel = state.uri.queryParameters['channel'] ?? 'sms';
          final retryAfter = int.tryParse(state.uri.queryParameters['retryAfter'] ?? '') ?? 180;
          return OtpScreen(phone: phone, channel: channel, retryAfter: retryAfter);
        },
      ),
      GoRoute(
        path: '/name-input',
        builder: (_, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return NameInputScreen(phone: phone);
        },
      ),
      GoRoute(
        path: '/role-selection',
        builder: (_, __) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/invite/:invitationId',
        builder: (_, state) {
          final invitationId = state.pathParameters['invitationId']!;
          return InviteScreen(invitationId: invitationId);
        },
      ),
      GoRoute(
        path: '/teacher',
        redirect: (_, __) => '/teacher/home',
      ),
      GoRoute(
        path: '/teacher/home',
        builder: (_, __) => const TeacherHomeScreen(),
      ),
      GoRoute(
        path: '/student',
        redirect: (_, __) => '/student/home',
      ),
      GoRoute(
        path: '/student/home',
        builder: (_, __) => const StudentHomeScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        redirect: (_, state) => state.extra == null ? '/welcome' : null,
        builder: (_, state) => EditProfileScreen(user: state.extra as User),
      ),
      GoRoute(
        path: '/profile/notifications',
        builder: (_, __) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/class/:classId',
        builder: (_, state) {
          final classId = state.pathParameters['classId']!;
          return ClassDetailScreen(classId: classId);
        },
      ),
      GoRoute(
        path: '/course/create',
        builder: (_, state) {
          final classId = state.uri.queryParameters['classId'] ?? '';
          return CreateCourseScreen(classId: classId);
        },
      ),
      GoRoute(
        path: '/course/:courseId',
        builder: (_, state) {
          final courseId = state.pathParameters['courseId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final classId = extra?['classId'] as String?;
          return CourseDetailScreen(courseId: courseId, classId: classId);
        },
      ),
      GoRoute(
        path: '/test/:sessionId',
        builder: (_, state) {
          final sid = state.pathParameters['sessionId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final courseItem = extra?['courseItem'] as CourseItem?;
          return TestPreviewScreen(sessionId: sid, courseItem: courseItem);
        },
      ),
      GoRoute(
        path: '/test/:sessionId/results',
        builder: (_, state) {
          final sid = state.pathParameters['sessionId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final courseItem = extra?['courseItem'] as CourseItem?;
          // extra is null only if navigating without context.push (e.g., deep link).
          // Defaulting to false is the correct security posture: deny teacher access.
          final isTeacher = extra?['isTeacher'] as bool? ?? false;
          return TestSessionResultsScreen(
            sessionId: sid,
            courseItem: courseItem,
            isTeacher: isTeacher,
          );
        },
      ),
      GoRoute(
        path: '/test/:sessionId/monitor',
        builder: (_, state) {
          final sid = state.pathParameters['sessionId']!;
          final extra = state.extra as Map<String, dynamic>?;
          final courseItem = extra?['courseItem'] as CourseItem?;
          final classId = extra?['classId'] as String? ?? '';
          return TestMonitoringScreen(
            sessionId: sid,
            classId: classId,
            courseItem: courseItem,
          );
        },
      ),
      GoRoute(
        path: '/test/:sessionId/attempts/:attemptId',
        builder: (_, state) {
          final aid = state.pathParameters['attemptId']!;
          return AttemptReviewScreen(attemptId: aid);
        },
      ),
      GoRoute(
        path: '/test/:sessionId/attempts/:attemptId/grade',
        builder: (_, state) {
          final aid = state.pathParameters['attemptId']!;
          return TeacherGradeAttemptScreen(attemptId: aid);
        },
      ),
    ],
  );
  return _routerInstance!;
}

String? _redirect(BuildContext context, GoRouterState state) {
  final authBloc = getIt<AuthBloc>();
  final authState = authBloc.state;
  final location = state.uri.path;

  final isAuthPath = location == '/splash' ||
      location == '/welcome' ||
      location == '/phone' ||
      location.startsWith('/otp') ||
      location == '/name-input' ||
      location == '/role-selection';

  if (authState is AuthInitial) {
    if (location != '/splash') return '/splash';
    return null;
  }

  if (authState is AuthLoading) {
    return null;
  }

  if (authState is AuthUnauthenticated || authState is AuthOtpSent) {
    // /invite доступен без авторизации — показываем экран с предложением войти
    if (location.startsWith('/invite')) return null;
    if (!isAuthPath || location == '/splash') return '/welcome';
    return null;
  }

  if (authState is AuthNameRequired) {
    final encoded = Uri.encodeComponent(authState.phone);
    if (!location.startsWith('/name-input')) return '/name-input?phone=$encoded';
    return null;
  }

  if (authState is AuthRoleRequired) {
    final pendingRole = getIt<DeepLinkService>().consumePendingRole();
    if (pendingRole != null) {
      getIt<ProfileStorage>().saveRole(pendingRole);
      getIt<AuthBloc>().add(const RoleSelectedEvent());
      return null;
    }
    if (location != '/role-selection') return '/role-selection';
    return null;
  }

  if (authState is AuthAuthenticated) {
    final deepLink = getIt<DeepLinkService>().consumePendingRoute();
    debugPrint('[Router] _redirect called, location=$location, deepLink=$deepLink');
    if (deepLink != null) {
      // Navigate to home first, then push the deep link on top so the user
      // has something to go back to.
      final homeRoute = _homeRoute(authState);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _routerInstance?.push(deepLink);
      });
      if (isAuthPath || location == homeRoute) return homeRoute;
      // Already on a non-auth screen — push on top without redirecting
      WidgetsBinding.instance.addPostFrameCallback((_) {});
      return null;
    }

    if (isAuthPath) {
      return _homeRoute(authState);
    }
    return null;
  }

  if (authState is AuthError) {
    return null;
  }

  return null;
}

String _homeRoute(AuthAuthenticated authState) {
  final role = authState.user.role ??
      _roleFromString(getIt<ProfileStorage>().getRole());
  if (role == UserRole.teacher) return '/teacher/home';
  if (role == UserRole.student) return '/student/home';
  return '/role-selection';
}

UserRole? _roleFromString(String? role) {
  if (role == 'teacher') return UserRole.teacher;
  if (role == 'student') return UserRole.student;
  return null;
}
