import 'package:edium/domain/entities/student_dashboard.dart';

part 'student_dashboard_model_recent_grade_item_model.dart';
part 'student_dashboard_model_active_test_item_model.dart';


class StudentDashboardModel {
  final List<RecentGradeItemModel> recentGrades;
  final List<ActiveTestItemModel> activeTests;

  const StudentDashboardModel({
    required this.recentGrades,
    required this.activeTests,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    final grades = (json['recent_grades'] as List<dynamic>? ?? [])
        .map((e) => RecentGradeItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final tests = (json['active_tests'] as List<dynamic>? ?? [])
        .map((e) => ActiveTestItemModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return StudentDashboardModel(recentGrades: grades, activeTests: tests);
  }

  StudentDashboard toEntity() => StudentDashboard(
        recentGrades: recentGrades.map((m) => m.toEntity()).toList(),
        activeTests: activeTests.map((m) => m.toEntity()).toList(),
      );
}

