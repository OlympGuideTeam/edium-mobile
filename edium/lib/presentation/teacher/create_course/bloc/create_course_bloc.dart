import 'package:edium/domain/usecases/course/create_course_usecase.dart';
import 'package:edium/domain/usecases/course/create_module_usecase.dart';
import 'package:edium/presentation/teacher/create_course/bloc/create_course_event.dart';
import 'package:edium/presentation/teacher/create_course/bloc/create_course_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateCourseBloc extends Bloc<CreateCourseEvent, CreateCourseState> {
  final CreateCourseUsecase _createCourse;
  final CreateModuleUsecase _createModule;

  CreateCourseBloc(this._createCourse, this._createModule)
      : super(const CreateCourseState()) {
    on<UpdateCourseTitleEvent>(
        (e, emit) => emit(state.copyWith(title: e.title)));
    on<AddModuleEvent>(
        (_, emit) => emit(state.copyWith(modules: [...state.modules, ''])));
    on<UpdateModuleEvent>((e, emit) {
      final updated = List<String>.from(state.modules);
      updated[e.index] = e.title;
      emit(state.copyWith(modules: updated));
    });
    on<RemoveModuleEvent>((e, emit) {
      final updated = List<String>.from(state.modules)..removeAt(e.index);
      emit(state.copyWith(modules: updated));
    });
    on<SubmitCourseEvent>(_onSubmit);
  }

  Future<void> _onSubmit(
    SubmitCourseEvent event,
    Emitter<CreateCourseState> emit,
  ) async {
    if (!state.canSubmit) return;
    emit(state.copyWith(isSubmitting: true));
    try {
      final courseId = await _createCourse(
        title: state.title.trim(),
        classId: event.classId,
      );

      final validModules =
          state.modules.where((m) => m.trim().isNotEmpty).toList();
      if (validModules.isNotEmpty) {
        await Future.wait(
          validModules
              .map((m) => _createModule(courseId: courseId, title: m.trim())),
        );
      }

      emit(state.copyWith(isSubmitting: false, success: true));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: e.toString()));
    }
  }
}
