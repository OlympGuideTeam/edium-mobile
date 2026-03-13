import 'package:edium/domain/entities/user.dart';

abstract class IUserRepository {
  Future<User> getMe();
  Future<User> setRole(UserRole role);
}
