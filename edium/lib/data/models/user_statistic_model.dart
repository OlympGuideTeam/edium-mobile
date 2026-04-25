class UserStatisticModel {
  final int classTeacherCount;
  final int studentCount;
  final int courseTeacherCount;
  final int courseStudentCount;

  const UserStatisticModel({
    required this.classTeacherCount,
    required this.studentCount,
    required this.courseTeacherCount,
    required this.courseStudentCount,
  });

  factory UserStatisticModel.fromJson(Map<String, dynamic> json) {
    return UserStatisticModel(
      classTeacherCount: json['class_teacher_count'] as int? ?? 0,
      studentCount: json['student_count'] as int? ?? 0,
      courseTeacherCount: json['course_teacher_count'] as int? ?? 0,
      courseStudentCount: json['course_student_count'] as int? ?? 0,
    );
  }
}

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
