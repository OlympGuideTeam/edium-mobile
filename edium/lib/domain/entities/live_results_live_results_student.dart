part of 'live_results.dart';

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

