part of 'quiz.dart';

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


  final int? listedQuestionCount;


  final bool isPublic;


  final bool needEvaluation;

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
    this.isPublic = false,
    this.needEvaluation = false,
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
    bool? isPublic,
    bool? needEvaluation,
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
      isPublic: isPublic ?? this.isPublic,
      needEvaluation: needEvaluation ?? this.needEvaluation,
    );
  }
}

