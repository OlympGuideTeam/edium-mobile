import 'package:edium/domain/entities/attempt_review.dart';
import 'package:equatable/equatable.dart';

abstract class AttemptReviewBlocState extends Equatable {
  const AttemptReviewBlocState();
  @override
  List<Object?> get props => [];
}

class AttemptReviewInitial extends AttemptReviewBlocState {
  const AttemptReviewInitial();
}

class AttemptReviewLoading extends AttemptReviewBlocState {
  const AttemptReviewLoading();
}

class AttemptReviewLoaded extends AttemptReviewBlocState {
  final AttemptReview review;
  const AttemptReviewLoaded(this.review);
  @override
  List<Object?> get props => [review];
}

class AttemptReviewError extends AttemptReviewBlocState {
  final String message;
  const AttemptReviewError(this.message);
  @override
  List<Object?> get props => [message];
}
