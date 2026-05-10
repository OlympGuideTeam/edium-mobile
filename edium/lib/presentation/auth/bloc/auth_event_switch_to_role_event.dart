part of 'auth_event.dart';

class SwitchToRoleEvent extends AuthEvent {
  final String role;

  const SwitchToRoleEvent(this.role);

  @override
  List<Object?> get props => [role];
}

