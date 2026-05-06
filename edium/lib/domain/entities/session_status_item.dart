class SessionStatusItem {
  final String sessionId;

  /// test | live
  final String mode;

  /// not_started | waiting | active | running | finished
  final String status;

  /// null для test-сессий.
  /// pending | lobby | question_active | question_locked | completed
  final String? phase;

  const SessionStatusItem({
    required this.sessionId,
    required this.mode,
    required this.status,
    this.phase,
  });
}
