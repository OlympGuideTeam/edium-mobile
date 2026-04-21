import 'package:edium/domain/entities/question.dart';

enum QuizStatus { draft, active, completed, future }

class QuizSettings {
  final int? timeLimitMinutes;
  final bool shuffleQuestions;
  final bool showExplanations;
  final DateTime? deadline;

  /// Riddler `default_settings.mode` (`test` | `live`), when present.
  final String? riddlerMode;

  /// Riddler `default_settings.question_time_limit_sec` (live).
  final int? questionTimeLimitSec;

  /// Riddler `default_settings.started_at` / `finished_at` (test window).
  final DateTime? sessionStartedAt;
  final DateTime? sessionFinishedAt;

  const QuizSettings({
    this.timeLimitMinutes,
    this.shuffleQuestions = false,
    this.showExplanations = true,
    this.deadline,
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
      riddlerMode: riddlerMode ?? this.riddlerMode,
      questionTimeLimitSec: questionTimeLimitSec ?? this.questionTimeLimitSec,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      sessionFinishedAt: sessionFinishedAt ?? this.sessionFinishedAt,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String? description;
  final String subject;
  final String authorId;
  final String authorName;
  final QuizStatus status;
  final QuizSettings settings;
  final List<Question> questions;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  /// Riddler list endpoints return [question_count] without embedding questions.
  final int? listedQuestionCount;

  const Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.subject,
    required this.authorId,
    required this.authorName,
    required this.status,
    required this.settings,
    required this.questions,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
    this.listedQuestionCount,
  });

  int get questionsCount => listedQuestionCount ?? questions.length;

  Quiz copyWith({
    String? id,
    String? title,
    String? description,
    bool clearDescription = false,
    String? subject,
    String? authorId,
    String? authorName,
    QuizStatus? status,
    QuizSettings? settings,
    List<Question>? questions,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
    int? listedQuestionCount,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      subject: subject ?? this.subject,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      questions: questions ?? this.questions,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      listedQuestionCount: listedQuestionCount ?? this.listedQuestionCount,
    );
  }
}
