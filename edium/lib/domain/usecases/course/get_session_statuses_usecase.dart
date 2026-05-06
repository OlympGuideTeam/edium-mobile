import 'package:edium/domain/entities/session_status_item.dart';
import 'package:edium/domain/repositories/course_repository.dart';

class GetSessionStatusesUsecase {
  final ICourseRepository _repository;

  GetSessionStatusesUsecase(this._repository);

  Future<Map<String, SessionStatusItem>> call(List<String> sessionIds) {
    return _repository.getSessionStatuses(sessionIds);
  }
}
