class UserStatisticModel {
  final int quizCountCreated;
  final int classTeacherCount;
  final int studentCount;
  final int courseStudentCount;
  final int quizCountPassed;
  final double avgQuizScore;

  const UserStatisticModel({
    required this.quizCountCreated,
    required this.classTeacherCount,
    required this.studentCount,
    required this.courseStudentCount,
    required this.quizCountPassed,
    required this.avgQuizScore,
  });

  factory UserStatisticModel.fromJson(Map<String, dynamic> json) {
    return UserStatisticModel(
      quizCountCreated: json['quiz_count_created'] as int? ?? 0,
      classTeacherCount: json['class_teacher_count'] as int? ?? 0,
      studentCount: json['student_count'] as int? ?? 0,
      courseStudentCount: json['course_student_count'] as int? ?? 0,
      quizCountPassed: json['quiz_count_passed'] as int? ?? 0,
      avgQuizScore: (json['avg_quiz_score'] as num?)?.toDouble() ?? 0.0,
    );
  }

}
