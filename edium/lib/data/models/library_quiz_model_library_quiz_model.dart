part of 'library_quiz_model.dart';

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
  final List<QuizAttemptSummaryModel> attempts;

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
    this.attempts = const [],
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
      attempts: (json['attempts'] as List<dynamic>? ?? [])
          .map((e) => QuizAttemptSummaryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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
        attempts: attempts.map((e) => e.toEntity()).toList(),
      );
}

