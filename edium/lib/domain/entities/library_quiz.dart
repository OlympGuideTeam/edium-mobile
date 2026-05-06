class QuizAttemptSummary {
  final String id;
  final String sessionId;
  final String sessionType;
  final String status;
  final double? score;
  final DateTime startedAt;
  final DateTime? finishedAt;

  const QuizAttemptSummary({
    required this.id,
    required this.sessionId,
    required this.sessionType,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
  });
}

class QuizDefaultSettings {
  final int? totalTimeLimitSec;
  final int? questionTimeLimitSec;
  final bool? shuffleQuestions;

  const QuizDefaultSettings({
    this.totalTimeLimitSec,
    this.questionTimeLimitSec,
    this.shuffleQuestions,
  });
}

class LibraryQuiz {
  final String id;
  final String title;
  final String? description;
  final String? subject;
  final QuizDefaultSettings defaultSettings;
  final bool isPublic;
  final bool isDraft;
  final bool needEvaluation;
  final int questionCount;
  final String? libraryTestSessionId;
  final List<QuizAttemptSummary> attempts;

  const LibraryQuiz({
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

  bool get hasTimeLimit => defaultSettings.totalTimeLimitSec != null;

  int? get timeLimitMinutes => defaultSettings.totalTimeLimitSec != null
      ? (defaultSettings.totalTimeLimitSec! / 60).ceil()
      : null;
}
