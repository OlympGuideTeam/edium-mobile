import 'package:edium/domain/entities/invitation_detail.dart';

part 'invite_state_invite_initial.dart';
part 'invite_state_invite_loading.dart';
part 'invite_state_invite_loaded.dart';
part 'invite_state_invite_accepting.dart';
part 'invite_state_invite_accept_success.dart';
part 'invite_state_invite_already_member.dart';
part 'invite_state_invite_declined.dart';
part 'invite_state_invite_accept_error.dart';
part 'invite_state_invite_load_error.dart';
part 'invite_state_invite_unauthenticated.dart';


abstract class InviteState {
  const InviteState();
}

