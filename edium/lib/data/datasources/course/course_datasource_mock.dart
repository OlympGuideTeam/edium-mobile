import 'package:edium/data/datasources/course/course_datasource.dart';

class CourseDatasourceMock implements ICourseDatasource {
  @override
  Future<String> createCourse({
    required String title,
    required String classId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'course-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> createModule({
    required String courseId,
    required String title,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
