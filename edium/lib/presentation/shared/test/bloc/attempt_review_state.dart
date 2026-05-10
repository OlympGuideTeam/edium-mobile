import 'package:edium/domain/entities/attempt_review.dart';
import 'package:equatable/equatable.dart';

part 'attempt_review_state_attempt_review_initial.dart';
part 'attempt_review_state_attempt_review_loading.dart';
part 'attempt_review_state_attempt_review_loaded.dart';
part 'attempt_review_state_attempt_review_error.dart';


abstract class AttemptReviewBlocState extends Equatable {
  const AttemptReviewBlocState();
  @override
  List<Object?> get props => [];
}

