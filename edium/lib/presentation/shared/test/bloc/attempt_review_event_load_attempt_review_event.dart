part of 'attempt_review_event.dart';

class LoadAttemptReviewEvent extends AttemptReviewEvent {
  final String attemptId;
  const LoadAttemptReviewEvent(this.attemptId);
  @override
  List<Object?> get props => [attemptId];
}

