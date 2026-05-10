import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/entities/user_statistic.dart';

part 'profile_state_profile_initial.dart';
part 'profile_state_profile_loading.dart';
part 'profile_state_profile_loaded.dart';
part 'profile_state_profile_error.dart';


abstract class ProfileState {
  const ProfileState();
}

