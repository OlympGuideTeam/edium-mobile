import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';

part 'live_student_state_live_student_initial.dart';
part 'live_student_state_live_student_connecting.dart';
part 'live_student_state_live_student_lobby.dart';
part 'live_student_state_live_student_question_active.dart';
part 'live_student_state_live_student_question_locked.dart';
part 'live_student_state_live_student_completed.dart';
part 'live_student_state_live_student_results_loading.dart';
part 'live_student_state_live_student_results_loaded.dart';
part 'live_student_state_live_student_kicked.dart';
part 'live_student_state_live_student_error.dart';


sealed class LiveStudentState {}

