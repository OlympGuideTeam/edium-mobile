part of 'live_teacher_state.dart';

class LiveTeacherQuestionLocked extends LiveTeacherState {
  final LiveQuestion question;
  final int questionIndex;
  final int questionTotal;
  final LiveCorrectAnswer correctAnswer;
  final LiveQuestionStats stats;

  final List<LiveLobbyParticipant> participants;
  final Map<String, LiveTeacherParticipantAnswer> answeredMap;

  final double timerFillAtLock;

  LiveTeacherQuestionLocked({
    required this.question,
    required this.questionIndex,
    required this.questionTotal,
    required this.correctAnswer,
    required this.stats,
    required this.participants,
    required this.answeredMap,
    required this.timerFillAtLock,
  });
}

