part of 'classes_state.dart';

class ClassesLoaded extends ClassesState {
  final List<ClassSummary> classes;
  final List<ClassSummary> filtered;
  final String searchQuery;

  const ClassesLoaded({
    required this.classes,
    required this.filtered,
    this.searchQuery = '',
  });
}

