import 'package:edium/domain/entities/user.dart';

abstract class EditProfileState {
  const EditProfileState();
}

class EditProfileInitial extends EditProfileState {
  final User user;

  const EditProfileInitial(this.user);
}

class EditProfileLoading extends EditProfileState {
  const EditProfileLoading();
}

class EditProfileSuccess extends EditProfileState {
  final User user;

  const EditProfileSuccess(this.user);
}

class EditProfileDeleted extends EditProfileState {
  const EditProfileDeleted();
}

class EditProfileError extends EditProfileState {
  final String message;

  const EditProfileError(this.message);
}
