import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:edium/domain/usecases/quiz/like_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz_session/get_my_sessions_usecase.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_event.dart';
import 'package:edium/presentation/student/quiz_library/bloc/student_quiz_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentQuizBloc extends Bloc<StudentQuizEvent, StudentQuizState> {
  final GetQuizzesUsecase _getQuizzes;
  final LikeQuizUsecase _likeQuiz;
  final GetMySessionsUsecase _getMySessions;

  StudentQuizBloc({
    required GetQuizzesUsecase getQuizzes,
    required LikeQuizUsecase likeQuiz,
    required GetMySessionsUsecase getMySessions,
  })  : _getQuizzes = getQuizzes,
        _likeQuiz = likeQuiz,
        _getMySessions = getMySessions,
        super(const StudentQuizInitial()) {
    on<LoadStudentQuizzesEvent>(_onLoad);
    on<StudentSearchChangedEvent>(_onSearch);
    on<StudentLikeQuizEvent>(_onLike);
  }

  Future<void> _onLoad(
    LoadStudentQuizzesEvent event,
    Emitter<StudentQuizState> emit,
  ) async {
    emit(const StudentQuizLoading());
    try {
      final all = await _getQuizzes(
        scope: 'global',
        search: event.search,
      );

      final quizzes = all
          .where((q) =>
              q.status.name == 'active' || q.settings.deadline != null)
          .toList();

      // Fetch sessions to determine quiz states for user
      final sessions = await _getMySessions();
      final completedMap = <String, ({int score, int total})>{};
      final inProgressMap = <String, String>{};

      for (final s in sessions) {
        if (s.status.name == 'completed' && s.score != null) {
          final total = s.totalQuestions ?? s.answers.length;
          final existing = completedMap[s.quizId];
          // Keep the best score per quiz
          if (existing == null || s.score! > existing.score) {
            completedMap[s.quizId] = (score: s.score!, total: total);
          }
        } else if (s.status.name == 'inProgress') {
          inProgressMap[s.quizId] = s.id;
        }
      }

      // If a quiz is completed, remove it from in-progress
      for (final quizId in completedMap.keys) {
        inProgressMap.remove(quizId);
      }

      emit(StudentQuizLoaded(quizzes, completedMap, inProgressMap));
    } catch (e) {
      emit(StudentQuizError(e.toString()));
    }
  }

  Future<void> _onSearch(
    StudentSearchChangedEvent event,
    Emitter<StudentQuizState> emit,
  ) async {
    add(LoadStudentQuizzesEvent(search: event.query));
  }

  Future<void> _onLike(
    StudentLikeQuizEvent event,
    Emitter<StudentQuizState> emit,
  ) async {
    if (state is! StudentQuizLoaded) return;
    final loaded = state as StudentQuizLoaded;
    try {
      final result = await _likeQuiz(event.quizId);
      final updated = loaded.quizzes.map((q) {
        if (q.id != event.quizId) return q;
        return q.copyWith(
            isLiked: result.liked, likesCount: result.likesCount);
      }).toList();
      emit(StudentQuizLoaded(
        updated,
        loaded.completedSessions,
        loaded.inProgressSessions,
      ));
    } catch (_) {}
  }
}
