import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/data/models/course_detail_model.dart';
import 'package:edium/domain/entities/course_detail.dart';
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

  @override
  Future<CourseDetail> getCourseDetail({required String courseId}) {
    return request(
      'caesar/v1/courses/$courseId',
      method: HttpMethod.get,
      parser: (data) =>
          CourseDetailModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<ModuleDetail> getModuleDetail({required String moduleId}) {
    return request(
      'caesar/v1/modules/$moduleId',
      method: HttpMethod.get,
      parser: (data) =>
          ModuleDetailModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }
}
