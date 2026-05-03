import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/repositories/course_repository.dart';
import 'package:edium/domain/repositories/live_repository.dart';

class GetActiveLobbyUsecase {
  final IClassRepository _classRepo;
  final ICourseRepository _courseRepo;
  final ILiveRepository _liveRepo;

  GetActiveLobbyUsecase({
    required IClassRepository classRepo,
    required ICourseRepository courseRepo,
    required ILiveRepository liveRepo,
  })  : _classRepo = classRepo,
        _courseRepo = courseRepo,
        _liveRepo = liveRepo;

  Future<LiveSessionMeta?> call() async {
    final classes = await _classRepo.getMyClasses(role: 'student');
    if (classes.isEmpty) return null;

    final classDetails = await Future.wait(
      classes.map((c) => _classRepo.getClassDetail(classId: c.id)),
    );

    final courseIds = <String>{};
    for (final detail in classDetails) {
      for (final course in detail.courses) {
        courseIds.add(course.id);
      }
    }
    if (courseIds.isEmpty) return null;

    final courseDetails = await Future.wait(
      courseIds.map((id) => _courseRepo.getCourseDetail(courseId: id)),
    );

    final moduleIds = <String>[];
    for (final course in courseDetails) {
      for (final module in course.modules) {
        if (module.elementCount > 0) {
          moduleIds.add(module.id);
        }
      }
    }
    if (moduleIds.isEmpty) return null;

    final moduleDetails = await Future.wait(
      moduleIds.map((id) => _courseRepo.getModuleDetail(moduleId: id)),
    );

    final liveSessionIds = <String>[];
    for (final module in moduleDetails) {
      for (final item in module.items) {
        if (item.quizType == 'live') {
          liveSessionIds.add(item.refId);
        }
      }
    }
    if (liveSessionIds.isEmpty) return null;

    final metas = await Future.wait(
      liveSessionIds.map((id) async {
        try {
          return await _liveRepo.getLiveSession(id);
        } catch (_) {
          return null;
        }
      }),
    );

    for (final meta in metas) {
      if (meta != null && meta.phase == LivePhase.lobby) {
        return meta;
      }
    }

    return null;
  }
}
