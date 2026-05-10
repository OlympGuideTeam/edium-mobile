import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_session.dart';

part 'live_ws_event_live_state_snapshot.dart';
part 'live_ws_event_live_locked_data.dart';
part 'live_ws_event_live_lobby_participant_joined.dart';
part 'live_ws_event_live_lobby_participant_left.dart';
part 'live_ws_event_live_quiz_started.dart';
part 'live_ws_event_live_question_started.dart';
part 'live_ws_event_live_participant_answered.dart';
part 'live_ws_event_live_question_stats_tick.dart';
part 'live_ws_event_live_question_locked.dart';
part 'live_ws_event_live_quiz_completed.dart';
part 'live_ws_event_live_participant_kicked.dart';
part 'live_ws_event_live_you_were_kicked.dart';
part 'live_ws_event_live_ws_error.dart';
part 'live_ws_event_live_ack.dart';
part 'live_ws_event_live_ws_disconnected.dart';



int? _liveQuestionIndexOneBasedFromPayload(num? raw) =>
    raw == null ? null : raw.toInt() + 1;

sealed class LiveWsEvent {}

