import 'package:edium/data/datasources/student_dashboard/student_dashboard_datasource.dart';
import 'package:edium/domain/entities/student_dashboard.dart';
import 'package:edium/domain/repositories/student_dashboard_repository.dart';

class StudentDashboardRepositoryImpl implements IStudentDashboardRepository {
  final IStudentDashboardDatasource _datasource;

  StudentDashboardRepositoryImpl(this._datasource);

  @override
  Future<StudentDashboard> getDashboard() async {
    final model = await _datasource.getDashboard();
    return model.toEntity();
  }
}
