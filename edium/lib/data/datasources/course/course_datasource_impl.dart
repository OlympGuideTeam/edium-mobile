import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/data/models/course_detail_model.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/session_status_item.dart';
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

  @override
  Future<void> deleteDraft(String draftId) {
    return request(
      'caesar/v1/drafts/$draftId',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }

  @override
  Future<void> deleteItem(String itemId) {
    return request(
      'caesar/v1/items/$itemId',
      method: HttpMethod.delete,
      parser: (_) {},
    );
  }

  @override
  Future<void> reorderModules({
    required String courseId,
    required List<String> moduleIds,
  }) {
    return request(
      'caesar/v1/courses/$courseId/modules/order',
      method: HttpMethod.patch,
      req: {'module_ids': moduleIds},
      parser: (_) {},
    );
  }

  @override
  Future<CourseSheet> getCourseSheet({required String courseId}) {
    return request(
      'caesar/v1/courses/$courseId/sheet',
      method: HttpMethod.get,
      parser: (data) =>
          CourseSheetModel.fromJson(data as Map<String, dynamic>).toEntity(),
    );
  }

  @override
  Future<Map<String, SessionStatusItem>> getSessionStatuses(
    List<String> sessionIds,
  ) {
    return request(
      'riddler/v1/sessions/statuses',
      method: HttpMethod.get,
      query: {'ids': sessionIds.join(',')},
      parser: (data) {
        final items =
            (data as Map<String, dynamic>)['items'] as List<dynamic>? ?? [];
        return {
          for (final e in items)
            (e as Map<String, dynamic>)['session_id'] as String:
                SessionStatusItem(
              sessionId: e['session_id'] as String,
              mode: e['mode'] as String,
              status: e['status'] as String,
              phase: e['phase'] as String?,
              attemptStatus: e['attempt_status'] as String?,
              score: (e['score'] as num?)?.toDouble(),
            ),
        };
      },
    );
  }
}
