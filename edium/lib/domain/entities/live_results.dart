import 'package:edium/domain/entities/attempt_review.dart' show TeacherAnswerOption;
import 'package:edium/domain/entities/live_question.dart';

class LiveAnswerReview {
  final String submissionId;
  final String questionId;
  final String questionType;
  final String questionText;
  final Map<String, dynamic> answerData;
  final double? finalScore;
  final String? finalSource;
  final String? finalFeedback;
  final List<TeacherAnswerOption>? options;
  final Map<String, dynamic>? metadata;

  const LiveAnswerReview({
    required this.submissionId,
    required this.questionId,
    required this.questionType,
    required this.questionText,
    required this.answerData,
    this.finalScore,
    this.finalSource,
    this.finalFeedback,
    this.options,
    this.metadata,
  });

  factory LiveAnswerReview.fromJson(Map<String, dynamic> json) =>
      LiveAnswerReview(
        submissionId: json['submission_id'] as String? ?? '',
        questionId: json['question_id'] as String? ?? '',
        questionType: json['question_type'] as String? ?? '',
        questionText: json['question_text'] as String? ?? '',
        answerData: (json['answer_data'] as Map<String, dynamic>?) ?? {},
        finalScore: (json['final_score'] as num?)?.toDouble(),
        finalSource: json['final_source'] as String?,
        finalFeedback: json['final_feedback'] as String?,
        options: (json['options'] as List<dynamic>?)
            ?.map((e) => TeacherAnswerOption(
                  id: e['id'] as String? ?? '',
                  text: e['text'] as String? ?? '',
                  isCorrect: e['is_correct'] as bool? ?? false,
                ))
            .toList(),
        metadata: json['metadata'] as Map<String, dynamic>?,
      );
}

class LiveAttemptReview {
  final String attemptId;
  final String status;
  final double? score;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<LiveAnswerReview> answers;

  const LiveAttemptReview({
    required this.attemptId,
    required this.status,
    this.score,
    required this.startedAt,
    this.finishedAt,
    required this.answers,
  });

  factory LiveAttemptReview.fromJson(Map<String, dynamic> json) =>
      LiveAttemptReview(
        attemptId: json['attempt_id'] as String? ?? '',
        status: json['status'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble(),
        startedAt: json['started_at'] != null
            ? DateTime.parse(json['started_at'] as String)
            : DateTime.now(),
        finishedAt: json['finished_at'] != null
            ? DateTime.parse(json['finished_at'] as String)
            : null,
        answers: (json['answers'] as List<dynamic>? ?? [])
            .map((e) => LiveAnswerReview.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LiveLeaderboardRow {
  final int position;
  final String attemptId;
  final String? userId;
  final String name;
  final double score;
  final bool isMe;

  const LiveLeaderboardRow({
    required this.position,
    required this.attemptId,
    this.userId,
    required this.name,
    required this.score,
    required this.isMe,
  });

  factory LiveLeaderboardRow.fromJson(Map<String, dynamic> json) =>
      LiveLeaderboardRow(
        position: (json['position'] as num?)?.toInt() ?? 0,
        attemptId: json['attempt_id'] as String? ?? '',
        userId: json['user_id'] as String?,
        name: json['name'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
        isMe: json['is_me'] as bool? ?? false,
      );
}

class LiveResultsStudent {
  final int myPosition;
  final int totalParticipants;
  final double myScore;
  final double maxScore;
  final int correctCount;
  final int questionsCount;
  final List<LiveLeaderboardRow> top;

  const LiveResultsStudent({
    required this.myPosition,
    required this.totalParticipants,
    required this.myScore,
    required this.maxScore,
    required this.correctCount,
    required this.questionsCount,
    required this.top,
  });

  factory LiveResultsStudent.fromJson(Map<String, dynamic> json) =>
      LiveResultsStudent(
        myPosition: (json['my_position'] as num?)?.toInt() ?? 0,
        totalParticipants: (json['total_participants'] as num?)?.toInt() ?? 0,
        myScore: (json['my_score'] as num?)?.toDouble() ?? 0,
        maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
        correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
        questionsCount: (json['questions_count'] as num?)?.toInt() ?? 0,
        top: (json['top'] as List<dynamic>? ?? [])
            .map((e) => LiveLeaderboardRow.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class LiveResultsTeacherQuestion {
  final String questionId;
  final int orderIndex;
  final String text;
  final String type;
  final double correctRate;
  final LiveQuestionStats stats;

  const LiveResultsTeacherQuestion({
    required this.questionId,
    required this.orderIndex,
    required this.text,
    required this.type,
    required this.correctRate,
    required this.stats,
  });

  factory LiveResultsTeacherQuestion.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final answeredCount = (json['answered_count'] as num?)?.toInt() ?? 0;
    final correctCount = (json['correct_count'] as num?)?.toInt() ?? 0;
    final avgTimeMs = (json['avg_time_ms'] as num?)?.toInt();
    final isChoice = type == 'single_choice' || type == 'multiple_choice';

    final LiveQuestionStats stats;
    if (isChoice) {
      stats = LiveChoiceStats(
        answeredCount: answeredCount,
        correctCount: correctCount,
        avgTimeMs: avgTimeMs,
        distribution: (json['distribution'] as List<dynamic>? ?? [])
            .map((e) =>
                LiveOptionDistribution.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    } else {
      stats = LiveBinaryStats(
        answeredCount: answeredCount,
        correctCount: correctCount,
        avgTimeMs: avgTimeMs,
        incorrectCount: answeredCount - correctCount,
      );
    }

    return LiveResultsTeacherQuestion(
      questionId: json['question_id'] as String? ?? '',
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      text: json['text'] as String? ?? '',
      type: type,
      correctRate: (json['correct_rate'] as num?)?.toDouble() ?? 0,
      stats: stats,
    );
  }
}

class LiveResultsTeacherAttemptAnswer {
  final String questionId;
  final bool isCorrect;
  final double score;

  const LiveResultsTeacherAttemptAnswer({
    required this.questionId,
    required this.isCorrect,
    required this.score,
  });

  factory LiveResultsTeacherAttemptAnswer.fromJson(
          Map<String, dynamic> json) =>
      LiveResultsTeacherAttemptAnswer(
        questionId: json['question_id'] as String? ?? '',
        isCorrect: json['is_correct'] as bool? ?? false,
        score: (json['score'] as num?)?.toDouble() ?? 0,
      );
}

class LiveResultsTeacherAttempt {
  final int position;
  final String attemptId;
  final String? userId;
  final String name;
  final double score;
  final double maxScore;
  final int correctCount;
  final List<LiveResultsTeacherAttemptAnswer> answers;

  const LiveResultsTeacherAttempt({
    required this.position,
    required this.attemptId,
    this.userId,
    required this.name,
    required this.score,
    required this.maxScore,
    required this.correctCount,
    required this.answers,
  });

  factory LiveResultsTeacherAttempt.fromJson(Map<String, dynamic> json) =>
      LiveResultsTeacherAttempt(
        position: (json['position'] as num?)?.toInt() ?? 0,
        attemptId: json['attempt_id'] as String? ?? '',
        userId: json['user_id'] as String?,
        name: json['name'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
        maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
        correctCount: (json['correct_count'] as num?)?.toInt() ?? 0,
        answers: (json['answers'] as List<dynamic>? ?? [])
            .map((e) => LiveResultsTeacherAttemptAnswer.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );
}

class LiveResultsTeacher {
  final List<LiveResultsTeacherQuestion> questions;
  final List<LiveResultsTeacherAttempt> leaderboard;

  const LiveResultsTeacher({
    required this.questions,
    required this.leaderboard,
  });

  factory LiveResultsTeacher.fromJson(Map<String, dynamic> json) =>
      LiveResultsTeacher(
        questions: (json['questions'] as List<dynamic>? ?? [])
            .map((e) => LiveResultsTeacherQuestion.fromJson(
                e as Map<String, dynamic>))
            .toList(),
        leaderboard: (json['leaderboard'] as List<dynamic>? ?? [])
            .map((e) => LiveResultsTeacherAttempt.fromJson(
                e as Map<String, dynamic>))
            .toList(),
      );
}
