abstract class InviteState {
  const InviteState();
}

class InviteInitial extends InviteState {
  const InviteInitial();
}

class InviteAccepting extends InviteState {
  const InviteAccepting();
}

class InviteAcceptSuccess extends InviteState {
  const InviteAcceptSuccess();
}

class InviteAlreadyMember extends InviteState {
  const InviteAlreadyMember();
}

class InviteAcceptError extends InviteState {
  final String message;
  const InviteAcceptError(this.message);
}
