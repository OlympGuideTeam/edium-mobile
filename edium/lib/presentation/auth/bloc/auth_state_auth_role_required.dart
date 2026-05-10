part of 'auth_state.dart';

class AuthRoleRequired extends AuthState {
  final User user;

  const AuthRoleRequired(this.user);

  @override
  List<Object?> get props => [user];
}

