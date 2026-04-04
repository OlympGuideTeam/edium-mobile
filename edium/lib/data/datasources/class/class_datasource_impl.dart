import 'package:edium/data/datasources/class/class_datasource.dart';
import 'package:edium/data/models/class_summary_model.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class ClassDatasourceImpl extends BaseApiService implements IClassDatasource {
  ClassDatasourceImpl(super.dio);

  @override
  Future<List<ClassSummaryModel>> getMyClasses({required String role}) {
    return request(
      'caesar/v1/classes/me',
      method: HttpMethod.get,
      query: {'role': role},
      parser: (data) {
        final map = data as Map<String, dynamic>;
        final list = map['classes'] as List<dynamic>;
        return list
            .map((e) =>
                ClassSummaryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }
}
