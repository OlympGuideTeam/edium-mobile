import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/entities/user_statistic.dart';

abstract class IUserRepository {
  Future<User> getMe();
  Future<User> setRole(UserRole role);
  Future<User> updateProfile({required String name});
  Future<void> deleteAccount();
  Future<UserStatistic> getStatistic();
}
