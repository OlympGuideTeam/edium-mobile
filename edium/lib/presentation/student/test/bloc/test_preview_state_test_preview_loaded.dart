part of 'test_preview_state.dart';

class TestPreviewLoaded extends TestPreviewState {
  final TestSessionMeta meta;
  final TestPreviewStatus status;
  final AttemptReview? review;
  final String? cachedAttemptId;

  const TestPreviewLoaded({
    required this.meta,
    required this.status,
    this.review,
    this.cachedAttemptId,
  });

  @override
  List<Object?> get props => [meta, status, review, cachedAttemptId];
}

