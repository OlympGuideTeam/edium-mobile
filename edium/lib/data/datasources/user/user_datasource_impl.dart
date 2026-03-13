import 'package:edium/data/datasources/user/user_datasource.dart';
import 'package:edium/data/models/user_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class UserDatasourceImpl extends BaseApiService implements IUserDatasource {
  UserDatasourceImpl(super.dio);

  @override
  Future<UserModel> getMe() {
    return request(
      'api/v1/users/me',
      method: HttpMethod.get,
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<UserModel> setRole(String role) {
    return request(
      'api/v1/users/me',
      method: HttpMethod.patch,
      req: {'role': role},
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
