import 'package:equatable/equatable.dart';

part 'take_quiz_event_start_attempt_event.dart';
part 'take_quiz_event_set_answer_event.dart';
part 'take_quiz_event_go_next_event.dart';
part 'take_quiz_event_go_prev_event.dart';
part 'take_quiz_event_jump_to_question_event.dart';
part 'take_quiz_event_finish_attempt_event.dart';
part 'take_quiz_event_timer_tick_event.dart';


abstract class TakeQuizEvent extends Equatable {
  const TakeQuizEvent();
  @override
  List<Object?> get props => [];
}

