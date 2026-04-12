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

class CreateClassEvent extends ClassesEvent {
  final String title;

  const CreateClassEvent(this.title);
}

class DeleteClassEvent extends ClassesEvent {
  final String classId;

  const DeleteClassEvent(this.classId);
}
