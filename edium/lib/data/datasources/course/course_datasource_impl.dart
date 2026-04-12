import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/services/network/base_api_service.dart';
import 'package:edium/services/network/http_method.dart';

class CourseDatasourceImpl extends BaseApiService implements ICourseDatasource {
  CourseDatasourceImpl(super.dio);

  @override
  Future<String> createCourse({
    required String title,
    required String classId,
  }) {
    return request(
      'caesar/v1/courses',
      method: HttpMethod.post,
      req: {'title': title, 'class_id': classId},
      parser: (data) => (data as Map<String, dynamic>)['id'] as String,
    );
  }

  @override
  Future<void> createModule({
    required String courseId,
    required String title,
  }) {
    return request(
      'caesar/v1/courses/$courseId/modules',
      method: HttpMethod.post,
      req: {'title': title},
      parser: (_) {},
    );
  }
}
