part of 'classes_event.dart';

class SearchClassesEvent extends ClassesEvent {
  final String query;

  const SearchClassesEvent(this.query);
}

