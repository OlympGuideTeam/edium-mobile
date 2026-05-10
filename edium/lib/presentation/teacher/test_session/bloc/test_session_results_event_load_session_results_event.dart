part of 'test_session_results_event.dart';

class LoadSessionResultsEvent extends TestSessionResultsEvent {
  final String sessionId;
  final String title;
  final String? moduleId;

  final String? courseItemId;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const LoadSessionResultsEvent({
    required this.sessionId,
    required this.title,
    this.moduleId,
    this.courseItemId,
    this.startedAt,
    this.finishedAt,
  });

  @override
  List<Object?> get props => [sessionId, title, moduleId, courseItemId, startedAt, finishedAt];
}

