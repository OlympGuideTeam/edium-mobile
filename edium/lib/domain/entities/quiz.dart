import 'package:edium/domain/entities/question.dart';

part 'quiz_quiz.dart';


enum QuizStatus { draft, active, completed, future }

class QuizSettings {
  final int? timeLimitMinutes;
  final bool shuffleQuestions;
  final bool showExplanations;
  final DateTime? deadline;


  final int? totalTimeLimitSec;


  final String? riddlerMode;


  final int? questionTimeLimitSec;


  final DateTime? sessionStartedAt;
  final DateTime? sessionFinishedAt;

  const QuizSettings({
    this.timeLimitMinutes,
    this.shuffleQuestions = false,
    this.showExplanations = true,
    this.deadline,
    this.totalTimeLimitSec,
    this.riddlerMode,
    this.questionTimeLimitSec,
    this.sessionStartedAt,
    this.sessionFinishedAt,
  });

  QuizSettings copyWith({
    int? timeLimitMinutes,
    bool? shuffleQuestions,
    bool? showExplanations,
    DateTime? deadline,
    int? totalTimeLimitSec,
    String? riddlerMode,
    int? questionTimeLimitSec,
    DateTime? sessionStartedAt,
    DateTime? sessionFinishedAt,
  }) {
    return QuizSettings(
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      showExplanations: showExplanations ?? this.showExplanations,
      deadline: deadline ?? this.deadline,
      totalTimeLimitSec: totalTimeLimitSec ?? this.totalTimeLimitSec,
      riddlerMode: riddlerMode ?? this.riddlerMode,
      questionTimeLimitSec: questionTimeLimitSec ?? this.questionTimeLimitSec,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      sessionFinishedAt: sessionFinishedAt ?? this.sessionFinishedAt,
    );
  }
}

