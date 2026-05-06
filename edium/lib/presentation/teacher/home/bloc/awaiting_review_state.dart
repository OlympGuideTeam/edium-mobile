part of 'awaiting_review_cubit.dart';

sealed class AwaitingReviewState extends Equatable {
  const AwaitingReviewState();

  @override
  List<Object?> get props => [];
}

class AwaitingReviewInitial extends AwaitingReviewState {
  const AwaitingReviewInitial();
}

class AwaitingReviewLoading extends AwaitingReviewState {
  const AwaitingReviewLoading();
}

class AwaitingReviewLoaded extends AwaitingReviewState {
  final List<AwaitingReviewSession> sessions;
  const AwaitingReviewLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

class AwaitingReviewError extends AwaitingReviewState {
  final String message;
  const AwaitingReviewError(this.message);

  @override
  List<Object?> get props => [message];
}
