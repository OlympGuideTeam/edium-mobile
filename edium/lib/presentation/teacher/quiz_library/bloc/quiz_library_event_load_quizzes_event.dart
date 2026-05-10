part of 'quiz_library_event.dart';

class LoadQuizzesEvent extends QuizLibraryEvent {
  final String scope;
  final String? search;

  const LoadQuizzesEvent({this.scope = 'global', this.search});

  @override
  List<Object?> get props => [scope, search];
}

