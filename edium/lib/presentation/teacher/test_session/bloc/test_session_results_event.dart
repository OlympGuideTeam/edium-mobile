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

  const LoadSessionResultsEvent({
    required this.sessionId,
    required this.title,
    this.moduleId,
  });

  @override
  List<Object?> get props => [sessionId, title, moduleId];
}

class RefreshSessionResultsEvent extends TestSessionResultsEvent {
  const RefreshSessionResultsEvent();
}

class DeleteSessionEvent extends TestSessionResultsEvent {
  const DeleteSessionEvent();
}
