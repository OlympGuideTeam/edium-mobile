import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';

sealed class LiveStudentState {}

class LiveStudentInitial extends LiveStudentState {}

class LiveStudentConnecting extends LiveStudentState {}

class LiveStudentLobby extends LiveStudentState {
  final String quizTitle;
  final int questionCount;
  final List<LiveLobbyParticipant> participants;
  /// Учеников в классе по Caesar roster; null если roster не загружали.
  final int? classmatesTotal;

  LiveStudentLobby({
    required this.quizTitle,
    required this.questionCount,
    required this.participants,
    this.classmatesTotal,
  });

  LiveStudentLobby copyWith({
    List<LiveLobbyParticipant>? participants,
    int? classmatesTotal,
  }) =>
      LiveStudentLobby(
        quizTitle: quizTitle,
        questionCount: questionCount,
        participants: participants ?? this.participants,
        classmatesTotal: classmatesTotal ?? this.classmatesTotal,
      );
}

class LiveStudentQuestionActive extends LiveStudentState {
  final LiveQuestion question;
  final int questionIndex;
  final int questionTotal;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final Map<String, dynamic>? myAnswer; // non-null if already answered

  LiveStudentQuestionActive({
    required this.question,
    required this.questionIndex,
    required this.questionTotal,
    required this.deadlineAt,
    required this.timeLimitSec,
    this.myAnswer,
  });

  bool get hasAnswered => myAnswer != null;

  LiveStudentQuestionActive copyWith({Map<String, dynamic>? myAnswer}) =>
      LiveStudentQuestionActive(
        question: question,
        questionIndex: questionIndex,
        questionTotal: questionTotal,
        deadlineAt: deadlineAt,
        timeLimitSec: timeLimitSec,
        myAnswer: myAnswer ?? this.myAnswer,
      );
}

class LiveStudentQuestionLocked extends LiveStudentState {
  final LiveQuestion question;
  final int questionIndex;
  final int questionTotal;
  final LiveCorrectAnswer correctAnswer;
  final LiveQuestionStats stats;
  final LiveStudentResult? myResult;
  final List<String>? wordCloud;
  final Map<String, dynamic>? myAnswer;

  LiveStudentQuestionLocked({
    required this.question,
    required this.questionIndex,
    required this.questionTotal,
    required this.correctAnswer,
    required this.stats,
    this.myResult,
    this.wordCloud,
    this.myAnswer,
  });
}

class LiveStudentCompleted extends LiveStudentState {}

class LiveStudentResultsLoading extends LiveStudentState {}

class LiveStudentResultsLoaded extends LiveStudentState {
  final LiveResultsStudent results;
  final LiveAttemptReview? review;
  LiveStudentResultsLoaded(this.results, {this.review});
}

class LiveStudentKicked extends LiveStudentState {}

class LiveStudentError extends LiveStudentState {
  final String message;
  LiveStudentError(this.message);
}
