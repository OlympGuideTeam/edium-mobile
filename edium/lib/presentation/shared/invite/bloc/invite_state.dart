import 'package:edium/domain/entities/invitation_detail.dart';

abstract class InviteState {
  const InviteState();
}

class InviteInitial extends InviteState {
  const InviteInitial();
}

class InviteLoading extends InviteState {
  const InviteLoading();
}

class InviteLoaded extends InviteState {
  final InvitationDetail detail;
  const InviteLoaded(this.detail);
}

class InviteAccepting extends InviteState {
  const InviteAccepting();
}

class InviteAcceptSuccess extends InviteState {
  final String classId;
  const InviteAcceptSuccess(this.classId);
}

class InviteAlreadyMember extends InviteState {
  const InviteAlreadyMember();
}

class InviteDeclined extends InviteState {
  const InviteDeclined();
}

class InviteAcceptError extends InviteState {
  final String message;
  const InviteAcceptError(this.message);
}

class InviteLoadError extends InviteState {
  final String message;
  const InviteLoadError(this.message);
}

class InviteUnauthenticated extends InviteState {
  const InviteUnauthenticated();
}
