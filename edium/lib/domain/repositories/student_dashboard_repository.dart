import 'package:edium/domain/entities/student_dashboard.dart';

abstract class IStudentDashboardRepository {
  Future<StudentDashboard> getDashboard();
}
