import 'dart:convert';

import 'package:edium/data/models/quiz_attempt_model.dart';

class AttemptCacheEntry {
  final String sessionId;
  final String attemptId;
  final List<QuizQuestionForStudentModel> questions;
  final Map<String, Map<String, dynamic>> answers;
  final DateTime startedAt;
  final DateTime? expiresAt;

  const AttemptCacheEntry({
    required this.sessionId,
    required this.attemptId,
    required this.questions,
    required this.answers,
    required this.startedAt,
    this.expiresAt,
  });

  AttemptCacheEntry copyWith({
    Map<String, Map<String, dynamic>>? answers,
  }) {
    return AttemptCacheEntry(
      sessionId: sessionId,
      attemptId: attemptId,
      questions: questions,
      answers: answers ?? this.answers,
      startedAt: startedAt,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'session_id': sessionId,
        'attempt_id': attemptId,
        'questions': questions.map((q) => q.toJson()).toList(),
        'answers': answers,
        'started_at': startedAt.toIso8601String(),
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
      };

  factory AttemptCacheEntry.fromJson(Map<String, dynamic> json) {
    final rawAnswers = (json['answers'] as Map<String, dynamic>? ?? {});
    return AttemptCacheEntry(
      sessionId: json['session_id'] as String,
      attemptId: json['attempt_id'] as String,
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => QuizQuestionForStudentModel.fromJson(
              e as Map<String, dynamic>))
          .toList(),
      answers: rawAnswers.map(
        (k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)),
      ),
      startedAt: DateTime.parse(json['started_at'] as String),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  String encode() => jsonEncode(toJson());

  static AttemptCacheEntry decode(String raw) =>
      AttemptCacheEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);

  bool isExpired(DateTime now) =>
      expiresAt != null && now.isAfter(expiresAt!);
}
