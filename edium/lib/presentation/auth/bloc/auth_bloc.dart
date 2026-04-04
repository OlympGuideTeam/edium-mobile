import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/usecases/auth/logout_usecase.dart';
import 'package:edium/domain/usecases/auth/send_otp_usecase.dart';
import 'package:edium/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:edium/domain/usecases/user/get_me_usecase.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUsecase sendOtp;
  final VerifyOtpUsecase verifyOtp;
  final LogoutUsecase logout;
  final GetMeUsecase getMe;
  final ProfileStorage profileStorage;

  AuthBloc({
    required this.sendOtp,
    required this.verifyOtp,
    required this.logout,
    required this.getMe,
    required this.profileStorage,
  }) : super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
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
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSendOtp(
    SendOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await sendOtp(phone: event.phone);
      emit(AuthOtpSent(event.phone));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
    VerifyOtpEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await verifyOtp(phone: event.phone, otp: event.otp);
      await profileStorage.savePhone(event.phone);

      // Check if we have a remembered name for this phone
      final savedName = profileStorage.getUserName(event.phone);
      if (savedName != null) {
        await profileStorage.saveName(savedName);
      }

      if (!profileStorage.hasName) {
        final user = await getMe();
        emit(AuthNameRequired(user));
      } else {
        final user = await getMe();
        if (user.role == null) {
          emit(AuthRoleRequired(user));
        } else {
          emit(AuthAuthenticated(user));
        }
      }
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
      // Persist name for this phone so we remember it after logout
      final phone = profileStorage.getPhone();
      if (phone != null) {
        await profileStorage.saveUserName(phone, event.name);
      }
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
      final user = await getMe();
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    LogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await logout();
      await profileStorage.clear();
    } catch (_) {}
    emit(const AuthUnauthenticated());
  }
}
