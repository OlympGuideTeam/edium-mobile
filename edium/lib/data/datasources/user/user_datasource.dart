import 'package:edium/data/models/user_model.dart';

abstract class IUserDatasource {
  Future<UserModel> getMe();
  Future<UserModel> setRole(String role);
}
