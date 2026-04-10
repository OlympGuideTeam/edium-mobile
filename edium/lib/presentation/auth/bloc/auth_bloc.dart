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
import 'package:edium/services/network/dio_handler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUsecase sendOtp;
  final VerifyOtpUsecase verifyOtp;
  final RegisterUsecase register;
  final LogoutUsecase logout;
  final GetMeUsecase getMe;
  final ProfileStorage profileStorage;
  final DioHandler dioHandler;

  AuthBloc({
    required this.sendOtp,
    required this.verifyOtp,
    required this.register,
    required this.logout,
    required this.getMe,
    required this.profileStorage,
    required this.dioHandler,
  }) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterEvent>(_onRegister);
    on<NameSubmittedEvent>(_onNameSubmitted);
    on<RoleSelectedEvent>(_onRoleSelected);
    on<LogoutEvent>(_onLogout);
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
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    if (event.channel == 'tg') {
      emit(AuthOtpSent(event.phone, channel: event.channel));
      return;
    }
    emit(const AuthLoading());
    try {
      await sendOtp(phone: event.phone, channel: event.channel);
      emit(AuthOtpSent(event.phone, channel: event.channel));
    } catch (e) {
      if (e is ApiException && e.code == 'OTP_ALREADY_SENT') {
        emit(AuthOtpSent(event.phone, channel: event.channel));
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
    emit(const AuthLoading());
    try {
      await logout();
      await profileStorage.clear();
    } catch (_) {}
    emit(const AuthUnauthenticated());
  }
}
