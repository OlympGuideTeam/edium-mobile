import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';

sealed class LiveTeacherState {}

class LiveTeacherInitial extends LiveTeacherState {}

class LiveTeacherConnecting extends LiveTeacherState {}

class LiveTeacherPending extends LiveTeacherState {
  final String quizTitle;
  final int questionCount;
  LiveTeacherPending({required this.quizTitle, required this.questionCount});
}

class LiveTeacherLobby extends LiveTeacherState {
  final String quizTitle;
  final int questionCount;
  final String? joinCode;
  final List<LiveLobbyParticipant> participants;

  LiveTeacherLobby({
    required this.quizTitle,
    required this.questionCount,
    this.joinCode,
    required this.participants,
  });

  LiveTeacherLobby copyWith({
    String? joinCode,
    List<LiveLobbyParticipant>? participants,
  }) =>
      LiveTeacherLobby(
        quizTitle: quizTitle,
        questionCount: questionCount,
        joinCode: joinCode ?? this.joinCode,
        participants: participants ?? this.participants,
      );
}

class LiveTeacherParticipantAnswer {
  final bool isCorrect;
  final int timeTakenMs;

  const LiveTeacherParticipantAnswer({
    required this.isCorrect,
    required this.timeTakenMs,
  });
}

class LiveTeacherQuestionActive extends LiveTeacherState {
  final LiveQuestion question;
  final int questionIndex;
  final int questionTotal;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final LiveQuestionStats? stats;
  /// All participants at question start (for name resolution).
  final List<LiveLobbyParticipant> participants;
  /// attemptId → answer result (populated as participants answer).
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

  /// Participants who haven't answered yet.
  List<LiveLobbyParticipant> get pendingParticipants =>
      participants.where((p) => !answeredMap.containsKey(p.attemptId)).toList();
}

class LiveTeacherQuestionLocked extends LiveTeacherState {
  final LiveQuestion question;
  final int questionIndex;
  final int questionTotal;
  final LiveCorrectAnswer correctAnswer;
  final LiveQuestionStats stats;
  /// Participant list with per-answer results for the locked view.
  final List<LiveLobbyParticipant> participants;
  final Map<String, LiveTeacherParticipantAnswer> answeredMap;
  /// Доля заполнения «таймерной» полоски активного сегмента в момент закрытия вопроса (0–1).
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

class LiveTeacherCompleted extends LiveTeacherState {}

class LiveTeacherResultsLoading extends LiveTeacherState {}

class LiveTeacherResultsLoaded extends LiveTeacherState {
  final LiveResultsTeacher results;
  LiveTeacherResultsLoaded(this.results);
}

class LiveTeacherError extends LiveTeacherState {
  final String message;
  LiveTeacherError(this.message);
}
