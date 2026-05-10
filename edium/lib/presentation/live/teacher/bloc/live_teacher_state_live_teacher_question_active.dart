part of 'live_teacher_state.dart';

class LiveTeacherQuestionActive extends LiveTeacherState {
  final LiveQuestion question;
  final int questionIndex;
  final int questionTotal;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final LiveQuestionStats? stats;

  final List<LiveLobbyParticipant> participants;

  final Map<String, LiveTeacherParticipantAnswer> answeredMap;
  final List<String> pendingAttemptIds;

  LiveTeacherQuestionActive({
    required this.question,
    required this.questionIndex,
    required this.questionTotal,
    required this.deadlineAt,
    required this.timeLimitSec,
    this.stats,
    required this.participants,
    required this.answeredMap,
    required this.pendingAttemptIds,
  });

  LiveTeacherQuestionActive copyWith({
    LiveQuestionStats? stats,
    Map<String, LiveTeacherParticipantAnswer>? answeredMap,
    List<String>? pendingAttemptIds,
  }) =>
      LiveTeacherQuestionActive(
        question: question,
        questionIndex: questionIndex,
        questionTotal: questionTotal,
        deadlineAt: deadlineAt,
        timeLimitSec: timeLimitSec,
        stats: stats ?? this.stats,
        participants: participants,
        answeredMap: answeredMap ?? this.answeredMap,
        pendingAttemptIds: pendingAttemptIds ?? this.pendingAttemptIds,
      );

  int get answeredCount => answeredMap.length;
  int get totalCount => participants.length;


  List<LiveLobbyParticipant> get pendingParticipants =>
      participants.where((p) => !answeredMap.containsKey(p.attemptId)).toList();
}

