import 'package:edium/domain/entities/student_dashboard.dart';
import 'package:edium/domain/repositories/student_dashboard_repository.dart';

class GetStudentDashboardUsecase {
  final IStudentDashboardRepository _repo;

  GetStudentDashboardUsecase(this._repo);

  Future<StudentDashboard> call() => _repo.getDashboard();
}
