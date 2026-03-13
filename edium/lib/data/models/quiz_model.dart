import 'package:edium/data/models/question_model.dart';
import 'package:edium/domain/entities/quiz.dart';

class QuizSettingsModel {
  final int? timeLimitMinutes;
  final bool shuffleQuestions;
  final bool showExplanations;
  final String? deadline;

  const QuizSettingsModel({
    this.timeLimitMinutes,
    this.shuffleQuestions = false,
    this.showExplanations = true,
    this.deadline,
  });

  factory QuizSettingsModel.fromJson(Map<String, dynamic> json) {
    return QuizSettingsModel(
      timeLimitMinutes: json['time_limit_minutes'] as int?,
      shuffleQuestions: json['shuffle_questions'] as bool? ?? false,
      showExplanations: json['show_explanations'] as bool? ?? true,
      deadline: json['deadline'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (timeLimitMinutes != null) 'time_limit_minutes': timeLimitMinutes,
        'shuffle_questions': shuffleQuestions,
        'show_explanations': showExplanations,
        if (deadline != null) 'deadline': deadline,
      };

  QuizSettings toEntity() => QuizSettings(
        timeLimitMinutes: timeLimitMinutes,
        shuffleQuestions: shuffleQuestions,
        showExplanations: showExplanations,
        deadline: deadline != null ? DateTime.tryParse(deadline!) : null,
      );

  factory QuizSettingsModel.fromEntity(QuizSettings s) => QuizSettingsModel(
        timeLimitMinutes: s.timeLimitMinutes,
        shuffleQuestions: s.shuffleQuestions,
        showExplanations: s.showExplanations,
        deadline: s.deadline?.toIso8601String(),
      );
}

class QuizModel {
  final String id;
  final String title;
  final String subject;
  final String authorId;
  final String authorName;
  final String status;
  final QuizSettingsModel settings;
  final List<QuestionModel> questions;
  final int likesCount;
  final bool isLiked;
  final String createdAt;

  const QuizModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.authorId,
    required this.authorName,
    required this.status,
    required this.settings,
    required this.questions,
    required this.likesCount,
    required this.isLiked,
    required this.createdAt,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      authorId: json['author_id'] as String,
      authorName: json['author_name'] as String,
      status: json['status'] as String? ?? 'draft',
      settings: QuizSettingsModel.fromJson(
          json['settings'] as Map<String, dynamic>? ?? {}),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuestionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      likesCount: json['likes_count'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subject': subject,
        'author_id': authorId,
        'author_name': authorName,
        'status': status,
        'settings': settings.toJson(),
        'questions': questions.map((e) => e.toJson()).toList(),
        'likes_count': likesCount,
        'is_liked': isLiked,
        'created_at': createdAt,
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
      subject: subject,
      authorId: authorId,
      authorName: authorName,
      status: quizStatus,
      settings: settings.toEntity(),
      questions: questions.map((e) => e.toEntity()).toList(),
      likesCount: likesCount,
      isLiked: isLiked,
      createdAt: DateTime.parse(createdAt),
    );
  }
}
