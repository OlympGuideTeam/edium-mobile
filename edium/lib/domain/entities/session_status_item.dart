class SessionStatusItem {
  final String sessionId;


  final String mode;


  final String status;


  final String? phase;


  final String? attemptStatus;


  final double? score;

  const SessionStatusItem({
    required this.sessionId,
    required this.mode,
    required this.status,
    this.phase,
    this.attemptStatus,
    this.score,
  });
}
