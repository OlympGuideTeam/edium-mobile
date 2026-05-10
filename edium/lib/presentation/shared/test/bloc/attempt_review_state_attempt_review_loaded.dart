part of 'attempt_review_state.dart';

class AttemptReviewLoaded extends AttemptReviewBlocState {
  final AttemptReview review;
  const AttemptReviewLoaded(this.review);
  @override
  List<Object?> get props => [review];
}

