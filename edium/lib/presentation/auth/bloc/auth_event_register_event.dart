part of 'auth_event.dart';

class RegisterEvent extends AuthEvent {
  final String phone;
  final String name;
  final String surname;

  const RegisterEvent({
    required this.phone,
    required this.name,
    required this.surname,
  });

  @override
  List<Object?> get props => [phone, name, surname];
}

