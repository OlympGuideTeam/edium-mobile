import 'package:equatable/equatable.dart';

abstract class AttemptReviewEvent extends Equatable {
  const AttemptReviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadAttemptReviewEvent extends AttemptReviewEvent {
  final String attemptId;
  const LoadAttemptReviewEvent(this.attemptId);
  @override
  List<Object?> get props => [attemptId];
}
