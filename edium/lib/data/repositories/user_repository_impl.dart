import 'package:edium/data/datasources/user/user_datasource.dart';
import 'package:edium/domain/entities/user.dart';
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
}
