import 'package:edium/domain/entities/library_quiz.dart';
import 'package:edium/domain/usecases/library_quiz/get_public_quizzes_usecase.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentQuizBloc extends Bloc<StudentQuizEvent, StudentQuizState> {
  final GetPublicQuizzesUsecase _getPublicQuizzes;

  StudentQuizBloc({required GetPublicQuizzesUsecase getPublicQuizzes})
      : _getPublicQuizzes = getPublicQuizzes,
        super(const StudentQuizInitial()) {
    on<LoadStudentQuizzesEvent>(_onLoad);
    on<StudentSearchChangedEvent>(_onSearch);
  }

  Future<void> _onLoad(
    LoadStudentQuizzesEvent event,
    Emitter<StudentQuizState> emit,
  ) async {
    emit(const StudentQuizLoading());
    try {
      final quizzes = await _getPublicQuizzes();
      final passed = _filterPassed(quizzes);
      emit(StudentQuizLoaded(
        quizzes: quizzes,
        filtered: quizzes,
        passedQuizzes: passed,
        filteredPassed: passed,
      ));
    } catch (e) {
      emit(StudentQuizError(e.toString()));
    }
  }

  void _onSearch(
    StudentSearchChangedEvent event,
    Emitter<StudentQuizState> emit,
  ) {
    final current = state;
    if (current is! StudentQuizLoaded) return;

    final query = event.query.toLowerCase().trim();
    if (query.isEmpty) {
      emit(StudentQuizLoaded(
        quizzes: current.quizzes,
        filtered: current.quizzes,
        passedQuizzes: current.passedQuizzes,
        filteredPassed: current.passedQuizzes,
      ));
      return;
    }

    final filtered = current.quizzes
        .where((q) => q.title.toLowerCase().contains(query))
        .toList();
    final filteredPassed = current.passedQuizzes
        .where((q) => q.title.toLowerCase().contains(query))
        .toList();
    emit(StudentQuizLoaded(
      quizzes: current.quizzes,
      filtered: filtered,
      passedQuizzes: current.passedQuizzes,
      filteredPassed: filteredPassed,
      searchQuery: event.query,
    ));
  }

  static List<LibraryQuiz> _filterPassed(List<LibraryQuiz> quizzes) =>
      quizzes.where((q) => q.attempts.isNotEmpty).toList();
}
