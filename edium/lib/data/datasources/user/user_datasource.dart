import 'package:edium/data/models/user_model.dart';
import 'package:edium/data/models/user_statistic_model.dart';

abstract class IUserDatasource {
  Future<UserModel> getMe();
  Future<UserModel> setRole(String role);
  Future<UserModel> updateProfile({required String name, required String surname});
  Future<void> deleteAccount();
  Future<UserStatisticModel> getStatistic();
}
