abstract class InviteEvent {
  const InviteEvent();
}

class InviteScreenOpened extends InviteEvent {
  const InviteScreenOpened();
}

class InviteAcceptRequested extends InviteEvent {
  const InviteAcceptRequested();
}
