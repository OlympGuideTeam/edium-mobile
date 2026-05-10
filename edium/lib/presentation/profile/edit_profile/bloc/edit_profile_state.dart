import 'package:edium/domain/entities/user.dart';

part 'edit_profile_state_edit_profile_initial.dart';
part 'edit_profile_state_edit_profile_loading.dart';
part 'edit_profile_state_edit_profile_success.dart';
part 'edit_profile_state_edit_profile_deleted.dart';
part 'edit_profile_state_edit_profile_error.dart';


abstract class EditProfileState {
  const EditProfileState();
}

