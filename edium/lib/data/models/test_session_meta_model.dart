import 'package:edium/domain/entities/test_session_meta.dart';

class TestSessionMetaModel {
  final String sessionId;
  final String quizId;
  final String title;
  final String? description;
  final int questionCount;
  final bool needEvaluation;
  final int? totalTimeLimitSec;
  final bool? shuffleQuestions;
  final String? startedAt;
  final String? finishedAt;

  const TestSessionMetaModel({
    required this.sessionId,
    required this.quizId,
    required this.title,
    this.description,
    required this.questionCount,
    required this.needEvaluation,
    this.totalTimeLimitSec,
    this.shuffleQuestions,
    this.startedAt,
    this.finishedAt,
  });

  /// Riddler `GET /quizzes/:id?role=student`. `library_test_session_id` — это
  /// sessionId для public library; для course-теста sessionId задан снаружи и
  /// приходит через параметр [fallbackSessionId].
  factory TestSessionMetaModel.fromStudentQuizJson(
    Map<String, dynamic> json, {
    String? fallbackSessionId,
  }) {
    final settings =
        (json['default_settings'] as Map<String, dynamic>?) ?? const {};
    return TestSessionMetaModel(
      sessionId: (json['library_test_session_id'] as String?) ??
          fallbackSessionId ??
          '',
      quizId: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      questionCount: (json['question_count'] as int?) ?? 0,
      needEvaluation: (json['need_evaluation'] as bool?) ?? false,
      totalTimeLimitSec: settings['total_time_limit_sec'] as int?,
      shuffleQuestions: settings['shuffle_questions'] as bool?,
      startedAt: settings['started_at'] as String?,
      finishedAt: settings['finished_at'] as String?,
    );
  }

  TestSessionMeta toEntity() => TestSessionMeta(
        sessionId: sessionId,
        quizId: quizId,
        title: title,
        description: description,
        questionCount: questionCount,
        needEvaluation: needEvaluation,
        totalTimeLimitSec: totalTimeLimitSec,
        shuffleQuestions: shuffleQuestions,
        startedAt: startedAt != null ? DateTime.tryParse(startedAt!) : null,
        finishedAt: finishedAt != null ? DateTime.tryParse(finishedAt!) : null,
      );
}
