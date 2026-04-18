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
  });

  bool get hasTimeLimit => defaultSettings.totalTimeLimitSec != null;

  int? get timeLimitMinutes => defaultSettings.totalTimeLimitSec != null
      ? (defaultSettings.totalTimeLimitSec! / 60).ceil()
      : null;
}
