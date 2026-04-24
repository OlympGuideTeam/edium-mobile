import 'package:edium/domain/entities/course_detail.dart';

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
}
