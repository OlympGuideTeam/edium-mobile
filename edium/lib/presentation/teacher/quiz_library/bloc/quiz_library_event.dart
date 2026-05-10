import 'package:equatable/equatable.dart';

part 'quiz_library_event_load_quizzes_event.dart';
part 'quiz_library_event_search_changed_event.dart';
part 'quiz_library_event_like_quiz_event.dart';
part 'quiz_library_event_delete_quiz_event.dart';


abstract class QuizLibraryEvent extends Equatable {
  const QuizLibraryEvent();
  @override
  List<Object?> get props => [];
}

