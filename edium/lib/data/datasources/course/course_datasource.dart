abstract class ICourseDatasource {
  Future<String> createCourse({required String title, required String classId});
  Future<void> createModule({required String courseId, required String title});
}
