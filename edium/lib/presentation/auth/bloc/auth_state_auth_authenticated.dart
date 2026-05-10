part of 'auth_state.dart';

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);


  @override
  List<Object?> get props => [user, user.role];
}

