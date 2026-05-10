part of 'user_statistic_model.dart';

class RiddlerUserStatisticModel {
  final int quizCountPassed;
  final double avgQuizScore;
  final int quizSessionsConducted;

  const RiddlerUserStatisticModel({
    required this.quizCountPassed,
    required this.avgQuizScore,
    required this.quizSessionsConducted,
  });

  factory RiddlerUserStatisticModel.fromJson(Map<String, dynamic> json) {
    return RiddlerUserStatisticModel(
      quizCountPassed: json['quiz_count_passed'] as int? ?? 0,
      avgQuizScore: (json['avg_quiz_score'] as num?)?.toDouble() ?? 0.0,
      quizSessionsConducted: json['quiz_sessions_conducted'] as int? ?? 0,
    );
  }
}

