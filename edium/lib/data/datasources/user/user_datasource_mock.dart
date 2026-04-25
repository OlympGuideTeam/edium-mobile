import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/data/datasources/user/user_datasource.dart';
import 'package:edium/data/models/user_model.dart';
import 'package:edium/data/models/user_statistic_model.dart';

class UserDatasourceMock implements IUserDatasource {
  final ProfileStorage _profileStorage;

  UserDatasourceMock(this._profileStorage);

  @override
  Future<UserModel> getMe() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel(
      id: 'mock-user-1',
      name: _profileStorage.getName() ?? '',
      surname: _profileStorage.getSurname() ?? 'Петров',
      phone: '+79991234567',
      role: _profileStorage.getRole(),
    );
  }

  @override
  Future<UserModel> setRole(String role) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _profileStorage.saveRole(role);
    return UserModel(
      id: 'mock-user-1',
      name: _profileStorage.getName() ?? '',
      surname: 'Петров',
      phone: '+79991234567',
      role: role,
    );
  }

  @override
  Future<UserModel> updateProfile({required String name, required String surname}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _profileStorage.saveName(name);
    await _profileStorage.saveSurname(surname);
    return UserModel(
      id: 'mock-user-1',
      name: name,
      surname: surname,
      phone: '+79991234567',
      role: _profileStorage.getRole(),
    );
  }

  @override
  Future<void> deleteAccount() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await _profileStorage.clear();
  }

  @override
  Future<UserStatisticModel> getStatistic() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const UserStatisticModel(
      classTeacherCount: 4,
      studentCount: 79,
      courseTeacherCount: 7,
      courseStudentCount: 3,
    );
  }

  @override
  Future<RiddlerUserStatisticModel> getRiddlerStatistic() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return const RiddlerUserStatisticModel(
      quizCountPassed: 24,
      avgQuizScore: 8.5,
      quizSessionsConducted: 12,
    );
  }
}
