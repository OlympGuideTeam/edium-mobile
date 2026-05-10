part of 'awaiting_review_cubit.dart';

class AwaitingReviewLoaded extends AwaitingReviewState {
  final List<AwaitingReviewSession> sessions;
  const AwaitingReviewLoaded(this.sessions);

  @override
  List<Object?> get props => [sessions];
}

