
part 'student_dashboard_recent_grade_item.dart';
part 'student_dashboard_active_test_item.dart';

class StudentDashboard {
  final List<RecentGradeItem> recentGrades;
  final List<ActiveTestItem> activeTests;

  const StudentDashboard({
    required this.recentGrades,
    required this.activeTests,
  });
}

