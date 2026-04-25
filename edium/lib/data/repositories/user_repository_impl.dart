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
  Future<User> updateProfile({required String name, required String surname}) async {
    final model = await _datasource.updateProfile(name: name, surname: surname);
    return model.toEntity();
  }

  @override
  Future<void> deleteAccount() async {
    await _datasource.deleteAccount();
  }

  @override
  Future<UserStatistic> getStatistic() async {
    final (caesar, riddler) = await (
      _datasource.getStatistic(),
      _datasource.getRiddlerStatistic(),
    ).wait;
    return UserStatistic(
      classTeacherCount: caesar.classTeacherCount,
      studentCount: caesar.studentCount,
      courseTeacherCount: caesar.courseTeacherCount,
      courseStudentCount: caesar.courseStudentCount,
      quizCountPassed: riddler.quizCountPassed,
      avgQuizScore: riddler.avgQuizScore,
      quizSessionsConducted: riddler.quizSessionsConducted,
    );
  }
}
