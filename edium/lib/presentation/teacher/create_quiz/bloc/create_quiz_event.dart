import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:equatable/equatable.dart';

part 'create_quiz_event_update_title_event.dart';
part 'create_quiz_event_update_description_event.dart';
part 'create_quiz_event_update_total_time_limit_event.dart';
part 'create_quiz_event_update_question_time_limit_event.dart';
part 'create_quiz_event_update_shuffle_questions_event.dart';
part 'create_quiz_event_add_question_event.dart';
part 'create_quiz_event_remove_question_event.dart';
part 'create_quiz_event_submit_quiz_event.dart';
part 'create_quiz_event_replace_question_event.dart';
part 'create_quiz_event_set_quiz_type_event.dart';
part 'create_quiz_event_update_started_at_event.dart';
part 'create_quiz_event_update_finished_at_event.dart';
part 'create_quiz_event_reset_create_quiz_event.dart';
part 'create_quiz_event_generate_quiz_questions_with_ai_event.dart';


abstract class CreateQuizEvent extends Equatable {
  const CreateQuizEvent();
  @override
  List<Object?> get props => [];
}

