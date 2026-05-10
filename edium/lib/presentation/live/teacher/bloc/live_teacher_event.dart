import 'package:edium/domain/entities/live_ws_event.dart';

part 'live_teacher_event_live_teacher_load.dart';
part 'live_teacher_event_live_teacher_ws_event.dart';
part 'live_teacher_event_live_teacher_start_lobby.dart';
part 'live_teacher_event_live_teacher_start_quiz.dart';
part 'live_teacher_event_live_teacher_next_question.dart';
part 'live_teacher_event_live_teacher_kick_participant.dart';
part 'live_teacher_event_live_teacher_load_results.dart';
part 'live_teacher_event_live_teacher_dispose.dart';


sealed class LiveTeacherEvent {}

