class NavigationBlockService {
  bool _isBlocked = false;
  bool get isBlocked => _isBlocked;

  void block() => _isBlocked = true;
  void unblock() => _isBlocked = false;
}
