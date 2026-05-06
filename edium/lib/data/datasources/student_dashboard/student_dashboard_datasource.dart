import 'package:edium/data/models/student_dashboard_model.dart';

abstract class IStudentDashboardDatasource {
  /// `GET /riddler/v1/sessions/dashboard`
  Future<StudentDashboardModel> getDashboard();
}
