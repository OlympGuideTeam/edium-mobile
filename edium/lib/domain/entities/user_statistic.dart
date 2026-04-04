class UserStatistic {
  final int quizCountCreated;
  final int classTeacherCount;
  final int studentCount;
  final int courseStudentCount;
  final int quizCountPassed;
  final double avgQuizScore;

  const UserStatistic({
    required this.quizCountCreated,
    required this.classTeacherCount,
    required this.studentCount,
    required this.courseStudentCount,
    required this.quizCountPassed,
    required this.avgQuizScore,
  });
}
