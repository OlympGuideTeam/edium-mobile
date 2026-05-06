import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/entities/session_status_item.dart';

abstract class ICourseDatasource {
  Future<String> createCourse({required String title, required String classId});
  Future<void> createModule({required String courseId, required String title});
  Future<CourseDetail> getCourseDetail({required String courseId});
  Future<ModuleDetail> getModuleDetail({required String moduleId});
  Future<void> deleteDraft(String draftId);
  Future<void> deleteItem(String itemId);
  Future<void> reorderModules({
    required String courseId,
    required List<String> moduleIds,
  });

  Future<CourseSheet> getCourseSheet({required String courseId});

  /// Batch-запрос статусов сессий из Riddler.
  /// Возвращает map sessionId → статус. Отсутствующие ID просто не попадают в map.
  Future<Map<String, SessionStatusItem>> getSessionStatuses(
    List<String> sessionIds,
  );
}
