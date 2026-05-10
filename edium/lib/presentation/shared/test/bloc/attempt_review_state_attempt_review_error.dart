part of 'attempt_review_state.dart';

class AttemptReviewError extends AttemptReviewBlocState {
  final String message;
  const AttemptReviewError(this.message);
  @override
  List<Object?> get props => [message];
}

