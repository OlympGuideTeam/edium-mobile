import 'package:edium/domain/entities/live_question.dart';

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

  factory LiveResultsTeacherQuestion.fromJson(Map<String, dynamic> json) =>
      LiveResultsTeacherQuestion(
        questionId: json['question_id'] as String? ?? '',
        orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
        text: json['text'] as String? ?? '',
        type: json['type'] as String? ?? '',
        correctRate: (json['correct_rate'] as num?)?.toDouble() ?? 0,
        stats: LiveQuestionStats.fromJson(
            json['stats'] as Map<String, dynamic>? ?? {}),
      );
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
