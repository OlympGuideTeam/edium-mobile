import 'dart:async';
import 'dart:io';

import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:edium/domain/usecases/auth/logout_usecase.dart';
import 'package:edium/domain/usecases/auth/register_usecase.dart';
import 'package:edium/domain/usecases/auth/send_otp_usecase.dart';
import 'package:edium/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:edium/domain/usecases/user/get_me_usecase.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:edium/services/network/dio_handler.dart';
import 'package:edium/services/notification_service/deep_link_service.dart';
import 'package:edium/services/notification_service/notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUsecase sendOtp;
  final VerifyOtpUsecase verifyOtp;
  final RegisterUsecase register;
  final LogoutUsecase logout;
  final GetMeUsecase getMe;
  final ProfileStorage profileStorage;
  final DioHandler dioHandler;
  final NotificationService notificationService;
  final IHeraldApiService heraldApiService;
  final DeepLinkService deepLinkService;

  StreamSubscription<String>? _tokenRefreshSub;

  AuthBloc({
    required this.sendOtp,
    required this.verifyOtp,
    required this.register,
    required this.logout,
    required this.getMe,
    required this.profileStorage,
    required this.dioHandler,
    required this.notificationService,
    required this.heraldApiService,
    required this.deepLinkService,
  }) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterEvent>(_onRegister);
    on<NameSubmittedEvent>(_onNameSubmitted);
    on<RoleSelectedEvent>(_onRoleSelected);
    on<LogoutEvent>(_onLogout);
    on<SwitchToRoleEvent>(_onSwitchToRole);
  }

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    if (!profileStorage.isLoggedIn) {
      emit(const AuthUnauthenticated());
      return;
    }
    final refreshed = await dioHandler.refreshTokens();
    if (!refreshed) {
      await profileStorage.clear();
      emit(const AuthUnauthenticated());
      return;
    }
    try {
      final user = await getMe();
      final savedRole = profileStorage.getRole();
      UserRole? role;
      if (savedRole == 'teacher') role = UserRole.teacher;
      if (savedRole == 'student') role = UserRole.student;

      if (role == null) {
        emit(AuthRoleRequired(user));
      } else {
        emit(AuthAuthenticated(user.copyWith(role: role)));
      }
      dioHandler.startProactiveRefresh();
      _registerFcmToken();
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (event.channel == 'tg') {
      emit(AuthOtpSent(event.phone, channel: event.channel, retryAfter: 0));
      return;
    }
    emit(const AuthLoading());
    try {
      final retryAfter = await sendOtp(phone: event.phone, channel: event.channel);
      emit(AuthOtpSent(event.phone, channel: event.channel, retryAfter: retryAfter));
    } catch (e) {
      if (e is ApiException && e.code == 'OTP_ALREADY_SENT') {
        final retryAfter = e.details?['retry_after'] as int? ?? 180;
        emit(AuthOtpSent(event.phone, channel: event.channel, retryAfter: retryAfter));
        return;
      }
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final isNewUser = await verifyOtp(phone: event.phone, otp: event.otp);

      if (isNewUser) {
        emit(AuthNameRequired(event.phone));
        return;
      }

      await dioHandler.syncTokenFromStorage();
      await profileStorage.savePhone(event.phone);
      final user = await getMe();
      await profileStorage.saveName(user.name);

      final savedRole = profileStorage.getRole();
      UserRole? role;
      if (savedRole == 'teacher') role = UserRole.teacher;
      if (savedRole == 'student') role = UserRole.student;

      if (role == null) {
        emit(AuthRoleRequired(user));
      } else {
        emit(AuthAuthenticated(user.copyWith(role: role)));
      }
      dioHandler.startProactiveRefresh();
      _registerFcmToken();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRegister(
    RegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await register(
        phone: event.phone,
        name: event.name,
        surname: event.surname,
      );
      await dioHandler.syncTokenFromStorage();
      await profileStorage.savePhone(event.phone);
      await profileStorage.saveName(event.name);
      final user = User(
        id: '',
        name: event.name,
        surname: event.surname,
        phone: event.phone,
      );
      emit(AuthRoleRequired(user));
      dioHandler.startProactiveRefresh();
      _registerFcmToken();
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onNameSubmitted(
    NameSubmittedEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await profileStorage.saveName(event.name);
      final user = await getMe();
      if (user.role == null) {
        emit(AuthRoleRequired(user));
      } else {
        emit(AuthAuthenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onRoleSelected(
    RoleSelectedEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final currentState = state;
      User user;
      if (currentState is AuthRoleRequired) {
        user = currentState.user;
      } else {
        user = await getMe();
      }
      final savedRole = profileStorage.getRole();
      UserRole? role;
      if (savedRole == 'teacher') role = UserRole.teacher;
      if (savedRole == 'student') role = UserRole.student;
      emit(AuthAuthenticated(user.copyWith(role: role)));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    dioHandler.stopProactiveRefresh();
    await _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
    emit(const AuthLoading());
    try {
      // TODO: unregister FCM token from Herald once backend supports token in logout
      // final token = await notificationService.getToken();
      // if (token != null) await heraldApiService.unregisterDevice(token);
      await logout();
      await profileStorage.clear();
    } catch (_) {}
    emit(const AuthUnauthenticated());
  }

  Future<void> _onSwitchToRole(
    SwitchToRoleEvent event,
    Emitter<AuthState> emit,
  ) async {
    final current = state;
    if (current is! AuthAuthenticated) {
      debugPrint('[Auth] SwitchToRole ignored: state is ${current.runtimeType}');
      return;
    }
    final role = event.role == 'teacher' ? UserRole.teacher : UserRole.student;
    debugPrint('[Auth] SwitchToRole ${current.user.role} → $role');
    await profileStorage.saveRole(event.role);
    emit(AuthAuthenticated(current.user.copyWith(role: role)));
  }

  void _registerFcmToken() {
    Future(() async {
      try {
        if (!profileStorage.hasAskedNotificationPermission) {
          await notificationService.requestPermission();
          await profileStorage.markNotificationPermissionAsked();
        }
        final token = await notificationService.getToken();
        if (token == null) return;
        final platform = Platform.isIOS ? 'ios' : 'android';
        await heraldApiService.registerDevice(token, platform);

        _tokenRefreshSub?.cancel();
        _tokenRefreshSub = notificationService.tokenRefreshStream.listen(
          (newToken) async {
            try {
              await heraldApiService.registerDevice(newToken, platform);
            } catch (_) {}
          },
        );
      } catch (_) {
        // Non-critical: app works without push notifications
      }
    });
  }
}
