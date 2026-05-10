import 'package:edium/domain/entities/quiz_attempt.dart';
import 'package:equatable/equatable.dart';

part 'take_quiz_state_take_quiz_initial.dart';
part 'take_quiz_state_take_quiz_loading.dart';
part 'take_quiz_state_take_quiz_in_progress.dart';
part 'take_quiz_state_take_quiz_finishing.dart';
part 'take_quiz_state_take_quiz_completed.dart';
part 'take_quiz_state_take_quiz_submitted.dart';
part 'take_quiz_state_take_quiz_error.dart';


abstract class TakeQuizState extends Equatable {
  const TakeQuizState();
  @override
  List<Object?> get props => [];
}

