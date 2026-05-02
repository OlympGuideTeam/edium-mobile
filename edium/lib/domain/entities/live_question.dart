import 'package:edium/domain/entities/question.dart';

class LiveAnswerOption {
  final String id;
  final String text;
  final bool? isCorrect; // null for students

  const LiveAnswerOption({
    required this.id,
    required this.text,
    this.isCorrect,
  });

  factory LiveAnswerOption.fromJson(Map<String, dynamic> json) =>
      LiveAnswerOption(
        id: json['id'] as String,
        text: json['text'] as String? ?? '',
        isCorrect: json['is_correct'] as bool?,
      );
}

class LiveQuestion {
  final String id;
  final QuestionType type;
  final String text;
  final String? imageId;
  final int maxScore;
  final List<LiveAnswerOption> options;
  final Map<String, dynamic>? metadata;

  const LiveQuestion({
    required this.id,
    required this.type,
    required this.text,
    this.imageId,
    required this.maxScore,
    required this.options,
    this.metadata,
  });

  factory LiveQuestion.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String? ?? 'single_choice';
    return LiveQuestion(
      id: json['id'] as String,
      type: _questionTypeFromString(typeStr),
      text: json['text'] as String? ?? '',
      imageId: json['image_id'] as String?,
      maxScore: (json['max_score'] as num?)?.toInt() ?? 10,
      options: (json['options'] as List<dynamic>? ?? [])
          .map((e) => LiveAnswerOption.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  static QuestionType _questionTypeFromString(String s) => switch (s) {
        'single_choice' => QuestionType.singleChoice,
        'multiple_choice' => QuestionType.multiChoice,
        'with_free_answer' => QuestionType.withFreeAnswer,
        'with_given_answer' => QuestionType.withGivenAnswer,
        'drag' => QuestionType.drag,
        'connection' => QuestionType.connection,
        _ => QuestionType.singleChoice,
      };
}

// ─── Stats ───────────────────────────────────────────────────────────────────

class LiveOptionDistribution {
  final String optionId;
  final int count;
  final bool isCorrect;

  const LiveOptionDistribution({
    required this.optionId,
    required this.count,
    required this.isCorrect,
  });

  factory LiveOptionDistribution.fromJson(Map<String, dynamic> json) =>
      LiveOptionDistribution(
        optionId: json['option_id'] as String,
        count: (json['count'] as num?)?.toInt() ?? 0,
        isCorrect: json['is_correct'] as bool? ?? false,
      );
}

sealed class LiveQuestionStats {
  final int answeredCount;
  final int correctCount;
  final int? avgTimeMs;

  const LiveQuestionStats({
    required this.answeredCount,
    required this.correctCount,
    this.avgTimeMs,
  });

  factory LiveQuestionStats.fromJson(Map<String, dynamic> json) {
    final kind = json['kind'] as String? ?? 'binary';
    if (kind == 'choice') {
      return LiveChoiceStats.fromJson(json);
    }
    return LiveBinaryStats.fromJson(json);
  }
}

class LiveChoiceStats extends LiveQuestionStats {
  final List<LiveOptionDistribution> distribution;

  const LiveChoiceStats({
    required super.answeredCount,
    required super.correctCount,
    super.avgTimeMs,
    required this.distribution,
  });

  factory LiveChoiceStats.fromJson(Map<String, dynamic> json) =>
      LiveChoiceStats(
        answeredCount: (json['answered_count'] as num?)?.toInt() ?? 0,
        correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
        avgTimeMs: (json['avg_time_ms'] as num?)?.toInt(),
        distribution: (json['distribution'] as List<dynamic>? ?? [])
            .map((e) =>
                LiveOptionDistribution.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LiveBinaryStats extends LiveQuestionStats {
  final int incorrectCount;

  const LiveBinaryStats({
    required super.answeredCount,
    required super.correctCount,
    super.avgTimeMs,
    required this.incorrectCount,
  });

  factory LiveBinaryStats.fromJson(Map<String, dynamic> json) =>
      LiveBinaryStats(
        answeredCount: (json['answered_count'] as num?)?.toInt() ?? 0,
        correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
        avgTimeMs: (json['avg_time_ms'] as num?)?.toInt(),
        incorrectCount: (json['incorrect_count'] as num?)?.toInt() ?? 0,
      );
}

// ─── Correct answer (shown after question_locked) ────────────────────────────

class LiveCorrectAnswer {
  final Map<String, dynamic> data;

  const LiveCorrectAnswer(this.data);

  factory LiveCorrectAnswer.fromJson(Map<String, dynamic> json) =>
      LiveCorrectAnswer(json);

  String? get correctOptionId => data['correct_option_id'] as String?;
  List<String>? get correctOptionIds =>
      (data['correct_option_ids'] as List<dynamic>?)?.cast<String>();
  List<String>? get correctAnswers =>
      (data['correct_answers'] as List<dynamic>?)?.cast<String>();
  List<String>? get correctOrder =>
      (data['correct_order'] as List<dynamic>?)?.cast<String>();
  Map<String, String>? get correctPairs =>
      (data['correct_pairs'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v as String));
}

// ─── Student result per question ─────────────────────────────────────────────

class LiveStudentResult {
  final bool isCorrect;
  final double score;
  final double maxScore;
  final int? timeTakenMs;

  const LiveStudentResult({
    required this.isCorrect,
    required this.score,
    required this.maxScore,
    this.timeTakenMs,
  });

  factory LiveStudentResult.fromJson(Map<String, dynamic> json) =>
      LiveStudentResult(
        isCorrect: json['is_correct'] as bool? ?? false,
        score: (json['score'] as num?)?.toDouble() ?? 0,
        maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
        timeTakenMs: (json['time_taken_ms'] as num?)?.toInt(),
      );
}
