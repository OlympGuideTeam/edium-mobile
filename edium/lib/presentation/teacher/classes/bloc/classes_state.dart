import 'package:edium/domain/entities/class_summary.dart';

abstract class ClassesState {
  const ClassesState();
}

class ClassesInitial extends ClassesState {
  const ClassesInitial();
}

class ClassesLoading extends ClassesState {
  const ClassesLoading();
}

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

class ClassesError extends ClassesState {
  final String message;

  const ClassesError(this.message);
}
