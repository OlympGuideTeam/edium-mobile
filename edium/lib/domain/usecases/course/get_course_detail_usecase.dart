import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/repositories/course_repository.dart';

class GetCourseDetailUsecase {
  final ICourseRepository _repository;

  GetCourseDetailUsecase(this._repository);

  Future<CourseDetail> call({required String courseId}) =>
      _repository.getCourseDetail(courseId: courseId);
}
