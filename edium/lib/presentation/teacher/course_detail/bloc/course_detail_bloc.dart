import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/domain/entities/course_detail.dart';
import 'package:edium/domain/repositories/course_repository.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
import 'package:edium/domain/usecases/course/get_course_detail_usecase.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_event.dart';
import 'package:edium/presentation/teacher/course_detail/bloc/course_detail_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CourseDetailBloc extends Bloc<CourseDetailEvent, CourseDetailState> {
  final GetCourseDetailUsecase _getCourseDetail;
  final CreateModuleUsecase _createModule;
  final ProfileStorage _profileStorage;
  final ICourseRepository _courseRepository;
  final String courseId;

  CourseDetailBloc({
    required GetCourseDetailUsecase getCourseDetail,
    required CreateModuleUsecase createModule,
    required ProfileStorage profileStorage,
    required ICourseRepository courseRepository,
    required this.courseId,
  })  : _getCourseDetail = getCourseDetail,
        _createModule = createModule,
        _profileStorage = profileStorage,
        _courseRepository = courseRepository,
        super(const CourseDetailInitial()) {
    on<LoadCourseDetailEvent>(_onLoad);
    on<SilentReloadCourseDetailEvent>(_onSilentReload);
    on<CreateModuleEvent>(_onCreateModule);
    on<DeleteDraftEvent>(_onDeleteDraft);
    on<ReorderModulesEvent>(_onReorderModules);
    on<OptimisticQuizAddedEvent>(_onOptimisticQuizAdded);
  }

  CourseDetail? get _currentCourse {
    final s = state;
    if (s is CourseDetailLoaded) return s.course;
    if (s is CourseModuleCreated) return s.course;
    if (s is CourseDetailActionError) return s.course;
    if (s is CourseDraftDeleted) return s.course;
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

  Future<void> _onSilentReload(
    SilentReloadCourseDetailEvent event,
    Emitter<CourseDetailState> emit,
  ) async {
    try {
      final course = await _getCourseDetail(courseId: event.courseId);
      emit(CourseDetailLoaded(course));
    } catch (_) {}
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

  Future<void> _onDeleteDraft(
    DeleteDraftEvent event,
    Emitter<CourseDetailState> emit,
  ) async {
    final current = _currentCourse;
    if (current == null) return;
    // Optimistic update: remove draft from list immediately
    final updatedDrafts = current.drafts
        .where((d) => d.id != event.draftId)
        .toList();
    final optimistic = CourseDetail(
      id: current.id,
      title: current.title,
      teacherName: current.teacherName,
      moduleCount: current.moduleCount,
      elementCount: current.elementCount,
      isTeacher: current.isTeacher,
      modules: current.modules,
      drafts: updatedDrafts,
    );
    emit(CourseDraftDeleted(optimistic));
    try {
      await _courseRepository.deleteDraft(event.draftId);
    } catch (e) {
      emit(CourseDetailActionError(e.toString(), current));
    }
  }

  Future<void> _onReorderModules(
    ReorderModulesEvent event,
    Emitter<CourseDetailState> emit,
  ) async {
    final current = _currentCourse;
    if (current == null) return;
    // Optimistic reorder
    final idToModule = {for (final m in current.modules) m.id: m};
    final reordered = event.moduleIds
        .map((id) => idToModule[id])
        .whereType<ModuleDetail>()
        .toList();
    final optimistic = CourseDetail(
      id: current.id,
      title: current.title,
      teacherName: current.teacherName,
      moduleCount: current.moduleCount,
      elementCount: current.elementCount,
      isTeacher: current.isTeacher,
      modules: reordered,
      drafts: current.drafts,
    );
    emit(CourseDetailLoaded(optimistic));
    try {
      await _courseRepository.reorderModules(
        courseId: courseId,
        moduleIds: event.moduleIds,
      );
    } catch (e) {
      emit(CourseDetailActionError(e.toString(), current));
    }
  }

  void _onOptimisticQuizAdded(
    OptimisticQuizAddedEvent event,
    Emitter<CourseDetailState> emit,
  ) {
    final current = _currentCourse;
    if (current == null) return;

    final payload = CourseItemPayload(
      title: event.title,
      mode: event.mode,
      totalTimeLimitSec: event.totalTimeLimitSec,
      questionTimeLimitSec: event.questionTimeLimitSec,
      shuffleQuestions: event.shuffleQuestions,
      startedAt: event.startedAt,
      finishedAt: event.finishedAt,
    );

    final optimisticId = 'opt_${DateTime.now().millisecondsSinceEpoch}';

    if (event.moduleId == null) {
      // saveOnly → quiz becomes a draft
      var drafts = current.drafts;
      if (event.existingTemplateId != null) {
        // editing existing draft + saveOnly → replace it in place
        drafts = drafts.map((d) {
          if (d.quizTemplateId != event.existingTemplateId) return d;
          return CourseDraft(
            id: d.id,
            quizTemplateId: d.quizTemplateId,
            payload: payload,
          );
        }).toList();
      } else {
        drafts = [...drafts, CourseDraft(id: optimisticId, quizTemplateId: optimisticId, payload: payload)];
      }
      emit(CourseDetailLoaded(CourseDetail(
        id: current.id,
        title: current.title,
        teacherName: current.teacherName,
        moduleCount: current.moduleCount,
        elementCount: current.elementCount,
        isTeacher: current.isTeacher,
        modules: current.modules,
        drafts: drafts,
      )));
    } else {
      // "Начать" → session created in a module
      var drafts = current.drafts;
      if (event.existingTemplateId != null) {
        // draft promoted to session → remove it from drafts
        drafts = drafts.where((d) => d.quizTemplateId != event.existingTemplateId).toList();
      }

      final updatedModules = current.modules.map((m) {
        if (m.id != event.moduleId) return m;
        return ModuleDetail(
          id: m.id,
          title: m.title,
          elementCount: m.elementCount + 1,
          items: [
            ...m.items,
            CourseItem(
              id: optimisticId,
              refId: optimisticId,
              type: 'quiz',
              orderIndex: m.elementCount,
              payload: payload,
            ),
          ],
        );
      }).toList();

      emit(CourseDetailLoaded(CourseDetail(
        id: current.id,
        title: current.title,
        teacherName: current.teacherName,
        moduleCount: current.moduleCount,
        elementCount: current.elementCount + 1,
        isTeacher: current.isTeacher,
        modules: updatedModules,
        drafts: drafts,
      )));
    }
  }
}
