
part 'user_statistic_model_riddler_user_statistic_model.dart';

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

