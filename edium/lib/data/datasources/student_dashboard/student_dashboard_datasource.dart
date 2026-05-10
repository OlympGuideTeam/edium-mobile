import 'package:edium/data/models/student_dashboard_model.dart';

abstract class IStudentDashboardDatasource {

  Future<StudentDashboardModel> getDashboard();
}
