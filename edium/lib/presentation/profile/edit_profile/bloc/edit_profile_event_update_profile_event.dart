part of 'edit_profile_event.dart';

class UpdateProfileEvent extends EditProfileEvent {
  final String name;
  final String surname;

  const UpdateProfileEvent({required this.name, required this.surname});
}

