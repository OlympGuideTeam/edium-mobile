import 'package:edium/domain/entities/quiz.dart';
import 'package:equatable/equatable.dart';

part 'quiz_library_state_quiz_library_initial.dart';
part 'quiz_library_state_quiz_library_loading.dart';
part 'quiz_library_state_quiz_library_loaded.dart';
part 'quiz_library_state_quiz_library_error.dart';


abstract class QuizLibraryState extends Equatable {
  const QuizLibraryState();
  @override
  List<Object?> get props => [];
}

