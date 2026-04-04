import 'package:edium/data/datasources/user/user_datasource.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/entities/user_statistic.dart';
import 'package:edium/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements IUserRepository {
  final IUserDatasource _datasource;

  UserRepositoryImpl(this._datasource);

  @override
  Future<User> getMe() async {
    final model = await _datasource.getMe();
    return model.toEntity();
  }

  @override
  Future<User> setRole(UserRole role) async {
    final model = await _datasource.setRole(role.name);
    return model.toEntity();
  }

  @override
  Future<User> updateProfile({required String name}) async {
    final model = await _datasource.updateProfile(name: name);
    return model.toEntity();
  }

  @override
  Future<void> deleteAccount() async {
    await _datasource.deleteAccount();
  }

  @override
  Future<UserStatistic> getStatistic() async {
    final model = await _datasource.getStatistic();
    return UserStatistic(
      quizCountCreated: model.quizCountCreated,
      classTeacherCount: model.classTeacherCount,
      studentCount: model.studentCount,
      courseStudentCount: model.courseStudentCount,
      quizCountPassed: model.quizCountPassed,
      avgQuizScore: model.avgQuizScore,
    );
  }
}
