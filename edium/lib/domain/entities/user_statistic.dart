class UserStatistic {
  final int classTeacherCount;
  final int studentCount;
  final int courseTeacherCount;
  final int courseStudentCount;
  final int quizCountPassed;
  final double avgQuizScore;
  final int quizSessionsConducted;

  const UserStatistic({
    required this.classTeacherCount,
    required this.studentCount,
    required this.courseTeacherCount,
    required this.courseStudentCount,
    required this.quizCountPassed,
    required this.avgQuizScore,
    required this.quizSessionsConducted,
  });
}
