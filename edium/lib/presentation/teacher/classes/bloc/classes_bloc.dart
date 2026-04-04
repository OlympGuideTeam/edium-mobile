import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_event.dart';
import 'package:edium/presentation/teacher/classes/bloc/classes_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClassesBloc extends Bloc<ClassesEvent, ClassesState> {
  final GetMyClassesUsecase _getMyClasses;
  final String role;

  ClassesBloc({
    required GetMyClassesUsecase getMyClasses,
    required this.role,
  })  : _getMyClasses = getMyClasses,
        super(const ClassesInitial()) {
    on<LoadClassesEvent>(_onLoad);
    on<SearchClassesEvent>(_onSearch);
  }

  Future<void> _onLoad(
    LoadClassesEvent event,
    Emitter<ClassesState> emit,
  ) async {
    emit(const ClassesLoading());
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
}
