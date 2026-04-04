abstract class EditProfileEvent {
  const EditProfileEvent();
}

class UpdateProfileEvent extends EditProfileEvent {
  final String name;

  const UpdateProfileEvent(this.name);
}

class DeleteAccountEvent extends EditProfileEvent {
  const DeleteAccountEvent();
}
