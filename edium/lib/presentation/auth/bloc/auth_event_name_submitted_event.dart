part of 'auth_event.dart';

class NameSubmittedEvent extends AuthEvent {
  final String name;

  const NameSubmittedEvent(this.name);

  @override
  List<Object?> get props => [name];
}

