part of 'live_results.dart';

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

