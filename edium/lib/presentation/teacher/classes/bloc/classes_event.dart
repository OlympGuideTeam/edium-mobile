abstract class ClassesEvent {
  const ClassesEvent();
}

class LoadClassesEvent extends ClassesEvent {
  const LoadClassesEvent();
}

class SearchClassesEvent extends ClassesEvent {
  final String query;

  const SearchClassesEvent(this.query);
}
