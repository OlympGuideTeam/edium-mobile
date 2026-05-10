part of 'test_preview_event.dart';

class LoadTestPreviewEvent extends TestPreviewEvent {
  final TestSessionMeta meta;


  final String? initialAttemptId;

  const LoadTestPreviewEvent({required this.meta, this.initialAttemptId});

  @override
  List<Object?> get props => [meta, initialAttemptId];
}

