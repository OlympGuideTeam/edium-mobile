import 'package:equatable/equatable.dart';

abstract class TestSessionResultsEvent extends Equatable {
  const TestSessionResultsEvent();
  @override
  List<Object?> get props => [];
}

class LoadSessionResultsEvent extends TestSessionResultsEvent {
  final String sessionId;
  final String title;
  final String? moduleId;
  /// ID элемента курса в Caesar (`DELETE /caesar/v1/items/{id}`), не session_id.
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

class RefreshSessionResultsEvent extends TestSessionResultsEvent {
  const RefreshSessionResultsEvent();
}

class DeleteSessionEvent extends TestSessionResultsEvent {
  const DeleteSessionEvent();
}

class FinishSessionEvent extends TestSessionResultsEvent {
  const FinishSessionEvent();
}

class PublishSessionEvent extends TestSessionResultsEvent {
  const PublishSessionEvent();
}
