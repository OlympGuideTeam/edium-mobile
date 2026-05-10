part of 'quiz_library_event.dart';

class SearchChangedEvent extends QuizLibraryEvent {
  final String query;
  const SearchChangedEvent(this.query);
  @override
  List<Object?> get props => [query];
}

