import 'package:edium/domain/usecases/class/create_class_usecase.dart';
import 'package:edium/domain/usecases/class/delete_class_usecase.dart';
import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_event.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final GetMyClassesUsecase _getMyClasses;
  final CreateClassUsecase _createClass;
  final DeleteClassUsecase _deleteClass;
  final String role;

  ClassesBloc({
    required GetMyClassesUsecase getMyClasses,
    required CreateClassUsecase createClass,
    required DeleteClassUsecase deleteClass,
    required this.role,
  })  : _getMyClasses = getMyClasses,
        _createClass = createClass,
        _deleteClass = deleteClass,
        super(const ClassesInitial()) {
    on<LoadClassesEvent>(_onLoad);
    on<SearchClassesEvent>(_onSearch);
    on<CreateClassEvent>(_onCreate);
    on<DeleteClassEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadClassesEvent event,
    Emitter<ClassesState> emit,
  ) async {
    if (state is! ClassesLoaded) emit(const ClassesLoading());
    try {
      final classes = await _getMyClasses(role: role);
      emit(ClassesLoaded(classes: classes, filtered: classes));
    } catch (e) {
      emit(ClassesError(e.toString()));
    }
  }

  void _onSearch(
    SearchClassesEvent event,
    Emitter<ClassesState> emit,
  ) {
    final current = state;
    if (current is! ClassesLoaded) return;

    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      emit(ClassesLoaded(
        classes: current.classes,
        filtered: current.classes,
        searchQuery: '',
      ));
      return;
    }

    final filtered = current.classes
        .where((c) => c.title.toLowerCase().contains(query))
        .toList();
    emit(ClassesLoaded(
      classes: current.classes,
      filtered: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onCreate(
    CreateClassEvent event,
    Emitter<ClassesState> emit,
  ) async {
    try {
      await _createClass(title: event.title);
      emit(const ClassCreated());
      add(const LoadClassesEvent());
    } catch (e) {
      emit(ClassCreateError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteClassEvent event,
    Emitter<ClassesState> emit,
  ) async {
    try {
      await _deleteClass(classId: event.classId);
      emit(const ClassDeleted());
      add(const LoadClassesEvent());
    } catch (e) {
      emit(ClassDeleteError(e.toString()));
    }
  }
}
