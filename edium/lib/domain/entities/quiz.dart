import 'package:edium/domain/entities/question.dart';

enum QuizStatus { draft, active, completed, future }

class QuizSettings {
  final int? timeLimitMinutes;
  final bool shuffleQuestions;
  final bool showExplanations;
  final DateTime? deadline;

  const QuizSettings({
    this.timeLimitMinutes,
    this.shuffleQuestions = false,
    this.showExplanations = true,
    this.deadline,
  });

  QuizSettings copyWith({
    int? timeLimitMinutes,
    bool? shuffleQuestions,
    bool? showExplanations,
    DateTime? deadline,
  }) {
    return QuizSettings(
      timeLimitMinutes: timeLimitMinutes ?? this.timeLimitMinutes,
      shuffleQuestions: shuffleQuestions ?? this.shuffleQuestions,
      showExplanations: showExplanations ?? this.showExplanations,
      deadline: deadline ?? this.deadline,
    );
  }
}

class Quiz {
  final String id;
  final String title;
  final String subject;
  final String authorId;
  final String authorName;
  final QuizStatus status;
  final QuizSettings settings;
  final List<Question> questions;
  final int likesCount;
  final bool isLiked;
  final DateTime createdAt;

  const Quiz({
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

  int get questionsCount => questions.length;

  Quiz copyWith({
    String? id,
    String? title,
    String? subject,
    String? authorId,
    String? authorName,
    QuizStatus? status,
    QuizSettings? settings,
    List<Question>? questions,
    int? likesCount,
    bool? isLiked,
    DateTime? createdAt,
  }) {
    return Quiz(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      status: status ?? this.status,
      settings: settings ?? this.settings,
      questions: questions ?? this.questions,
      likesCount: likesCount ?? this.likesCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
