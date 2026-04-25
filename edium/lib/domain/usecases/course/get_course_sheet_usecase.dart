import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/repositories/course_repository.dart';

class GetCourseSheetUsecase {
  final ICourseRepository _repository;

  GetCourseSheetUsecase(this._repository);

  Future<CourseSheet> call({required String courseId}) =>
      _repository.getCourseSheet(courseId: courseId);
}
