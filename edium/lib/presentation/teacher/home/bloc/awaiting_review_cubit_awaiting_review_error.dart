part of 'awaiting_review_cubit.dart';

class AwaitingReviewError extends AwaitingReviewState {
  final String message;
  const AwaitingReviewError(this.message);

  @override
  List<Object?> get props => [message];
}

