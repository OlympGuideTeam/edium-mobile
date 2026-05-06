import 'package:edium/data/datasources/student_dashboard/student_dashboard_datasource.dart';
import 'package:edium/data/models/student_dashboard_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class StudentDashboardDatasourceImpl extends BaseApiService
    implements IStudentDashboardDatasource {
  StudentDashboardDatasourceImpl(super.dio);

  @override
  Future<StudentDashboardModel> getDashboard() {
    return request(
      'riddler/v1/sessions/dashboard',
      method: HttpMethod.get,
      parser: (data) =>
          StudentDashboardModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
