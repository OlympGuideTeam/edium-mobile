import 'dart:async';

import 'package:edium/core/di/injection.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/presentation/auth/screens/name_input_screen.dart';
import 'package:edium/presentation/auth/screens/otp_screen.dart';
import 'package:edium/presentation/auth/screens/phone_input_screen.dart';
import 'package:edium/presentation/auth/screens/role_selection_screen.dart';
import 'package:edium/presentation/auth/screens/splash_screen.dart';
import 'package:edium/presentation/auth/screens/welcome_screen.dart';
import 'package:edium/presentation/profile/edit_profile/edit_profile_screen.dart';
import 'package:edium/presentation/student/home/student_home_screen.dart';
import 'package:edium/presentation/teacher/home/teacher_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _routerNotifier,
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
          return OtpScreen(phone: phone, channel: channel);
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
    ],
  );
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


  // Initial load — go to splash
  if (authState is AuthInitial) {
    if (location != '/splash') return '/splash';
    return null;
  }

  // Loading (e.g. sending OTP, verifying) — stay wherever we are
  if (authState is AuthLoading) {
    return null;
  }

  if (authState is AuthUnauthenticated || authState is AuthOtpSent) {
    if (!isAuthPath || location == '/splash') return '/welcome';
    return null;
  }

  if (authState is AuthNameRequired) {
    final encoded = Uri.encodeComponent(authState.phone);
    if (!location.startsWith('/name-input')) return '/name-input?phone=$encoded';
    return null;
  }

  if (authState is AuthRoleRequired) {
    if (location != '/role-selection') return '/role-selection';
    return null;
  }

  if (authState is AuthAuthenticated) {
    if (isAuthPath) {
      final role = authState.user.role ??
          _roleFromString(getIt<ProfileStorage>().getRole());
      if (role == UserRole.teacher) return '/teacher/home';
      if (role == UserRole.student) return '/student/home';
      return '/role-selection';
    }
    return null;
  }

  if (authState is AuthError) {
    return null;
  }

  return null;
}

UserRole? _roleFromString(String? role) {
  if (role == 'teacher') return UserRole.teacher;
  if (role == 'student') return UserRole.student;
  return null;
}
