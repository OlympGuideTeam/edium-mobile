import 'package:edium/data/datasources/user/user_datasource.dart';
import 'package:edium/data/models/user_model.dart';
import 'package:edium/data/models/user_statistic_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class UserDatasourceImpl extends BaseApiService implements IUserDatasource {
  UserDatasourceImpl(super.dio);

  @override
  Future<UserModel> getMe() {
    return request(
      'caesar/v1/users/me',
      method: HttpMethod.get,
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<UserModel> setRole(String role) {
    return request(
      'caesar/v1/users/me',
      method: HttpMethod.patch,
      req: {'role': role},
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<UserModel> updateProfile({required String name}) {
    return request(
      'caesar/v1/users/me',
      method: HttpMethod.patch,
      req: {'name': name},
      parser: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<void> deleteAccount() {
    return request(
      'caesar/v1/users/me',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }

  @override
  Future<UserStatisticModel> getStatistic() {
    return request(
      'caesar/v1/users/me/statistic',
      method: HttpMethod.get,
      parser: (data) =>
          UserStatisticModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
