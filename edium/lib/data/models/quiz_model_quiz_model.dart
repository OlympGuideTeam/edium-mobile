part of 'quiz_model.dart';

class QuizModel {
  final String id;
  final String title;
  final String? description;
  final String subject;
  final String authorId;
  final String authorName;
  final String status;
  final QuizSettingsModel settings;
  final List<QuestionModel> questions;
  final int likesCount;
  final bool isLiked;
  final String createdAt;


  final int? summaryQuestionCount;


  final bool isPublic;


  final bool needEvaluation;

  const QuizModel({
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
    this.summaryQuestionCount,
    this.isPublic = false,
    this.needEvaluation = false,
  });

  static QuizSettingsModel _settingsFromJson(Map<String, dynamic> json) {
    final def = json['default_settings'];
    if (def is Map<String, dynamic>) {
      return QuizSettingsModel.fromRiddlerDefaultSettings(def);
    }
    return QuizSettingsModel.fromJson(
      json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  static String _statusFromJson(Map<String, dynamic> json) {
    final raw = json['status'] as String?;
    if (raw != null && raw.isNotEmpty) return raw;
    final isDraft = json['is_draft'] as bool? ?? true;
    final isPublic = json['is_public'] as bool? ?? false;
    if (isDraft) return 'draft';
    if (isPublic) return 'active';
    return 'draft';
  }

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    final createdRaw = json['created_at'] as String?;
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      subject: json['subject'] as String? ?? '',
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      status: _statusFromJson(json),
      settings: _settingsFromJson(json),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: (createdRaw != null && createdRaw.isNotEmpty)
          ? createdRaw
          : DateTime.now().toUtc().toIso8601String(),
      summaryQuestionCount: json['question_count'] as int?,
      isPublic: json['is_public'] as bool? ?? false,
      needEvaluation: json['need_evaluation'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        'subject': subject,
        'author_id': authorId,
        'author_name': authorName,
        'status': status,
        'settings': settings.toJson(),
        'questions': questions.map((e) => e.toJson()).toList(),
        'likes_count': likesCount,
        'is_liked': isLiked,
        'created_at': createdAt,
        if (summaryQuestionCount != null)
          'question_count': summaryQuestionCount,
        'is_public': isPublic,
        'need_evaluation': needEvaluation,
      };

  Quiz toEntity() {
    QuizStatus quizStatus;
    switch (status) {
      case 'active':
        quizStatus = QuizStatus.active;
        break;
      case 'completed':
        quizStatus = QuizStatus.completed;
        break;
      case 'future':
        quizStatus = QuizStatus.future;
        break;
      default:
        quizStatus = QuizStatus.draft;
    }
    return Quiz(
      id: id,
      title: title,
      description: description,
      subject: subject,
      authorId: authorId,
      authorName: authorName,
      status: quizStatus,
      settings: settings.toEntity(),
      questions: questions.map((e) => e.toEntity()).toList(),
      likesCount: likesCount,
      isLiked: isLiked,
      createdAt: DateTime.parse(createdAt),
      listedQuestionCount: summaryQuestionCount,
      isPublic: isPublic,
      needEvaluation: needEvaluation,
    );
  }
}

