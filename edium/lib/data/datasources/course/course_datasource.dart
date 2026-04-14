import 'package:edium/domain/entities/course_detail.dart';

abstract class ICourseDatasource {
  Future<String> createCourse({required String title, required String classId});
  Future<void> createModule({required String courseId, required String title});
  Future<CourseDetail> getCourseDetail({required String courseId});
}
