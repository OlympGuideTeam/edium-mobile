part of 'auth_state.dart';

class AuthNameRequired extends AuthState {
  final String phone;

  const AuthNameRequired(this.phone);

  @override
  List<Object?> get props => [phone];
}

