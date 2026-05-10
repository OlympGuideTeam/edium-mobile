part of 'live_ws_event.dart';

class LiveWsDisconnected extends LiveWsEvent {}


LiveWsEvent? parseLiveWsEvent(Map<String, dynamic> json) {
  final type = json['type'] as String?;
  final data = json['data'] as Map<String, dynamic>? ?? {};
  return switch (type) {
    'state.snapshot' => LiveStateSnapshot.fromJson(json),
    'lobby.participant_joined' => LiveLobbyParticipantJoined.fromJson(data),
    'lobby.participant_left' => LiveLobbyParticipantLeft.fromJson(data),
    'quiz.started' => LiveQuizStarted(),
    'question.started' => LiveQuestionStarted.fromJson(data),
    'participant.answered' => LiveParticipantAnswered.fromJson(data),
    'question.stats_tick' => LiveQuestionStatsTick.fromJson(data),
    'question.locked' => LiveQuestionLocked.fromJson(data),
    'quiz.completed' => LiveQuizCompleted(),
    'participant.kicked' => LiveParticipantKicked.fromJson(data),
    'you_were_kicked' => LiveYouWereKicked.fromJson(data),
    'error' => LiveWsError.fromJson(data),
    'ack' => LiveAck.fromJson(data),
    _ => null,
  };
}

