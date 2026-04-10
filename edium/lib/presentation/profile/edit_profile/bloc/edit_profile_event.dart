abstract class EditProfileEvent {
  const EditProfileEvent();
}

class UpdateProfileEvent extends EditProfileEvent {
  final String name;
  final String surname;

  const UpdateProfileEvent({required this.name, required this.surname});
}

class DeleteAccountEvent extends EditProfileEvent {
  const DeleteAccountEvent();
}
