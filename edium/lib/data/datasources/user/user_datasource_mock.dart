import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/data/datasources/user/user_datasource.dart';
import 'package:edium/data/models/user_model.dart';

class UserDatasourceMock implements IUserDatasource {
  final ProfileStorage _profileStorage;

  UserDatasourceMock(this._profileStorage);

  @override
  Future<UserModel> getMe() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel(
      id: 'mock-user-1',
      name: _profileStorage.getName() ?? '',
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
      phone: '+79991234567',
      role: role,
    );
  }
}
