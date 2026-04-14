import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_event.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final GetCourseDetailUsecase _getCourseDetail;
  final CreateModuleUsecase _createModule;
  final String courseId;

  CourseDetailBloc({
    required GetCourseDetailUsecase getCourseDetail,
    required CreateModuleUsecase createModule,
    required this.courseId,
  })  : _getCourseDetail = getCourseDetail,
        _createModule = createModule,
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

  Future<void> _onLoad(
    LoadCourseDetailEvent event,
    Emitter<CourseDetailState> emit,
  ) async {
    emit(const CourseDetailLoading());
    try {
      final course = await _getCourseDetail(courseId: event.courseId);
      emit(CourseDetailLoaded(course));
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
      emit(CourseModuleCreated(updated));
    } catch (e) {
      emit(CourseDetailActionError(e.toString(), current));
    }
  }
}
