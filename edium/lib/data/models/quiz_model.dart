import 'package:edium/data/models/question_model.dart';
import 'package:edium/domain/entities/quiz.dart';

part 'quiz_model_quiz_model.dart';


class QuizSettingsModel {
  final int? timeLimitMinutes;
  final bool shuffleQuestions;
  final bool showExplanations;
  final String? deadline;
  final int? totalTimeLimitSec;
  final String? riddlerMode;
  final int? questionTimeLimitSec;
  final String? sessionStartedAtIso;
  final String? sessionFinishedAtIso;

  const QuizSettingsModel({
    this.timeLimitMinutes,
    this.shuffleQuestions = false,
    this.showExplanations = true,
    this.deadline,
    this.totalTimeLimitSec,
    this.riddlerMode,
    this.questionTimeLimitSec,
    this.sessionStartedAtIso,
    this.sessionFinishedAtIso,
  });

  factory QuizSettingsModel.fromJson(Map<String, dynamic> json) {
    return QuizSettingsModel(
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      shuffleQuestions: json['shuffle_questions'] as bool? ?? false,
      showExplanations: json['show_explanations'] as bool? ?? true,
      deadline: json['deadline'] as String?,
      totalTimeLimitSec: json['total_time_limit_sec'] as int?,
    );
  }


  factory QuizSettingsModel.fromRiddlerDefaultSettings(
    Map<String, dynamic> json,
  ) {
    final totalSec = json['total_time_limit_sec'] as int?;
    final startedRaw = json['started_at'];
    final finishedRaw = json['finished_at'];
    return QuizSettingsModel(
      timeLimitMinutes: (totalSec != null && totalSec > 0)
          ? (totalSec / 60).ceil()
          : null,
      shuffleQuestions: json['shuffle_questions'] as bool? ?? false,
      showExplanations: true,
      deadline: null,
      totalTimeLimitSec: (totalSec != null && totalSec > 0) ? totalSec : null,
      riddlerMode: json['mode'] as String?,
      questionTimeLimitSec: json['question_time_limit_sec'] as int?,
      sessionStartedAtIso:
          startedRaw is String ? startedRaw : null,
      sessionFinishedAtIso:
          finishedRaw is String ? finishedRaw : null,
    );
  }

  Map<String, dynamic> toJson() => {
        if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
        'shuffle_questions': shuffleQuestions,
        'show_explanations': showExplanations,
        if (deadline != null) 'deadline': deadline,
        if (totalTimeLimitSec != null)
          'total_time_limit_sec': totalTimeLimitSec,
        if (riddlerMode != null) 'mode': riddlerMode,
        if (questionTimeLimitSec != null)
          'question_time_limit_sec': questionTimeLimitSec,
        if (sessionStartedAtIso != null) 'started_at': sessionStartedAtIso,
        if (sessionFinishedAtIso != null) 'finished_at': sessionFinishedAtIso,
      };

  QuizSettings toEntity() => QuizSettings(
        timeLimitMinutes: timeLimitMinutes,
        shuffleQuestions: shuffleQuestions,
        showExplanations: showExplanations,
        deadline: deadline != null ? DateTime.tryParse(deadline!) : null,
        totalTimeLimitSec: totalTimeLimitSec,
        riddlerMode: riddlerMode,
        questionTimeLimitSec: questionTimeLimitSec,
        sessionStartedAt: sessionStartedAtIso != null
            ? DateTime.tryParse(sessionStartedAtIso!)
            : null,
        sessionFinishedAt: sessionFinishedAtIso != null
            ? DateTime.tryParse(sessionFinishedAtIso!)
            : null,
      );

  factory QuizSettingsModel.fromEntity(QuizSettings s) => QuizSettingsModel(
        timeLimitMinutes: s.timeLimitMinutes,
        shuffleQuestions: s.shuffleQuestions,
        showExplanations: s.showExplanations,
        deadline: s.deadline?.toIso8601String(),
        totalTimeLimitSec: s.totalTimeLimitSec,
        riddlerMode: s.riddlerMode,
        questionTimeLimitSec: s.questionTimeLimitSec,
        sessionStartedAtIso: s.sessionStartedAt?.toUtc().toIso8601String(),
        sessionFinishedAtIso: s.sessionFinishedAt?.toUtc().toIso8601String(),
      );
}

