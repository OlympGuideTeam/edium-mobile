import 'package:edium/domain/entities/user.dart';
import 'package:equatable/equatable.dart';

part 'auth_state_auth_initial.dart';
part 'auth_state_auth_loading.dart';
part 'auth_state_auth_otp_sent.dart';
part 'auth_state_auth_authenticated.dart';
part 'auth_state_auth_name_required.dart';
part 'auth_state_auth_role_required.dart';
part 'auth_state_auth_unauthenticated.dart';
part 'auth_state_auth_error.dart';


abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

