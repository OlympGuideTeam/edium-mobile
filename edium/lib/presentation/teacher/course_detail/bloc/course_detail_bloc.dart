import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_event.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final GetCourseDetailUsecase _getCourseDetail;
  final CreateModuleUsecase _createModule;
  final ProfileStorage _profileStorage;
  final String courseId;

  CourseDetailBloc({
    required GetCourseDetailUsecase getCourseDetail,
    required CreateModuleUsecase createModule,
    required ProfileStorage profileStorage,
    required this.courseId,
  })  : _getCourseDetail = getCourseDetail,
        _createModule = createModule,
        _profileStorage = profileStorage,
        super(const CourseDetailInitial()) {
    on<LoadCourseDetailEvent>(_onLoad);
    on<CreateModuleEvent>(_onCreateModule);
  }

  CourseDetail? get _currentCourse {
    final s = state;
    if (s is CourseDetailLoaded) return s.course;
    if (s is CourseModuleCreated) return s.course;
    if (s is CourseDetailActionError) return s.course;
    return null;
  }

  // Intersects the API-reported isTeacher with the current stored role.
  // Prevents teacher UI from appearing when the user is in student mode.
  CourseDetail _applyRoleGuard(CourseDetail course) {
    final isCurrentlyTeacher = _profileStorage.getRole() == 'teacher';
    return course.copyWith(isTeacher: course.isTeacher && isCurrentlyTeacher);
  }

  Future<void> _onLoad(
    LoadCourseDetailEvent event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(const CourseDetailLoading());
    try {
      final course = await _getCourseDetail(courseId: event.courseId);
      emit(CourseDetailLoaded(_applyRoleGuard(course)));
    } catch (e) {
      emit(CourseDetailError(e.toString()));
    }
  }

  Future<void> _onCreateModule(
    CreateModuleEvent event,
    Emitter<CourseDetailState> emit,
  ) async {
    final current = _currentCourse;
    if (current == null) return;
    try {
      await _createModule(courseId: courseId, title: event.title);
      final updated = await _getCourseDetail(courseId: courseId);
      emit(CourseModuleCreated(_applyRoleGuard(updated)));
    } catch (e) {
      emit(CourseDetailActionError(e.toString(), current));
    }
  }
}
