import 'package:edium/domain/entities/library_quiz.dart';

class QuizDefaultSettingsModel {
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool? shuffleQuestions;

  const QuizDefaultSettingsModel({
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions,
  });

  factory QuizDefaultSettingsModel.fromJson(Map<String, dynamic> json) {
    return QuizDefaultSettingsModel(
      totalTimeLimitSec: json['total_time_limit_sec'] as int?,
      questionTimeLimitSec: json['question_time_limit_sec'] as int?,
      shuffleQuestions: json['shuffle_questions'] as bool?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (totalTimeLimitSec != null)
          'total_time_limit_sec': totalTimeLimitSec,
        if (questionTimeLimitSec != null)
          'question_time_limit_sec': questionTimeLimitSec,
        if (shuffleQuestions != null) 'shuffle_questions': shuffleQuestions,
      };

  QuizDefaultSettings toEntity() => QuizDefaultSettings(
        totalTimeLimitSec: totalTimeLimitSec,
        questionTimeLimitSec: questionTimeLimitSec,
        shuffleQuestions: shuffleQuestions,
      );
}

class LibraryQuizModel {
  final String id;
  final String title;
  final String? description;
  final String? subject;
  final QuizDefaultSettingsModel defaultSettings;
  final bool isPublic;
  final bool isDraft;
  final bool needEvaluation;
  final int questionCount;
  final String? libraryTestSessionId;

  const LibraryQuizModel({
    required this.id,
    required this.title,
    this.description,
    this.subject,
    required this.defaultSettings,
    required this.isPublic,
    required this.isDraft,
    required this.needEvaluation,
    required this.questionCount,
    this.libraryTestSessionId,
  });

  factory LibraryQuizModel.fromJson(Map<String, dynamic> json) {
    return LibraryQuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      subject: json['subject'] as String?,
      defaultSettings: QuizDefaultSettingsModel.fromJson(
        json['default_settings'] as Map<String, dynamic>? ?? {},
      ),
      isPublic: json['is_public'] as bool? ?? true,
      isDraft: json['is_draft'] as bool? ?? false,
      needEvaluation: json['need_evaluation'] as bool? ?? false,
      questionCount: json['question_count'] as int? ?? 0,
      libraryTestSessionId: json['library_test_session_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        if (subject != null) 'subject': subject,
        'default_settings': defaultSettings.toJson(),
        'is_public': isPublic,
        'is_draft': isDraft,
        'need_evaluation': needEvaluation,
        'question_count': questionCount,
        if (libraryTestSessionId != null)
          'library_test_session_id': libraryTestSessionId,
      };

  LibraryQuiz toEntity() => LibraryQuiz(
        id: id,
        title: title,
        description: description,
        subject: subject,
        defaultSettings: defaultSettings.toEntity(),
        isPublic: isPublic,
        isDraft: isDraft,
        needEvaluation: needEvaluation,
        questionCount: questionCount,
        libraryTestSessionId: libraryTestSessionId,
      );
}
