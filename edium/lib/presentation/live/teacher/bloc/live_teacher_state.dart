import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';

part 'live_teacher_state_live_teacher_initial.dart';
part 'live_teacher_state_live_teacher_connecting.dart';
part 'live_teacher_state_live_teacher_pending.dart';
part 'live_teacher_state_live_teacher_lobby.dart';
part 'live_teacher_state_live_teacher_participant_answer.dart';
part 'live_teacher_state_live_teacher_question_active.dart';
part 'live_teacher_state_live_teacher_question_locked.dart';
part 'live_teacher_state_live_teacher_completed.dart';
part 'live_teacher_state_live_teacher_results_loading.dart';
part 'live_teacher_state_live_teacher_results_loaded.dart';
part 'live_teacher_state_live_teacher_error.dart';


sealed class LiveTeacherState {}

