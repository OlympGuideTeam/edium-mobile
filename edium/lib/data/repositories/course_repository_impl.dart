import 'package:edium/data/datasources/course/course_datasource.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/repositories/course_repository.dart';

class CourseRepositoryImpl implements ICourseRepository {
  final ICourseDatasource _datasource;

  CourseRepositoryImpl(this._datasource);

  @override
  Future<String> createCourse({
    required String title,
    required String classId,
  }) {
    return _datasource.createCourse(title: title, classId: classId);
  }

  @override
  Future<void> createModule({
    required String courseId,
    required String title,
  }) {
    return _datasource.createModule(courseId: courseId, title: title);
  }

  @override
  Future<CourseDetail> getCourseDetail({required String courseId}) {
    return _datasource.getCourseDetail(courseId: courseId);
  }

  @override
  Future<ModuleDetail> getModuleDetail({required String moduleId}) {
    return _datasource.getModuleDetail(moduleId: moduleId);
  }
}
