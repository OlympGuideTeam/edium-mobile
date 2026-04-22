import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:edium/domain/usecases/quiz/like_quiz_usecase.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_event.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuizLibraryBloc extends Bloc<QuizLibraryEvent, QuizLibraryState> {
  final GetQuizzesUsecase _getQuizzes;
  final LikeQuizUsecase _likeQuiz;
  final IQuizRepository _quizRepository;

  QuizLibraryBloc({
    required GetQuizzesUsecase getQuizzes,
    required LikeQuizUsecase likeQuiz,
    required IQuizRepository quizRepository,
  })  : _getQuizzes = getQuizzes,
        _likeQuiz = likeQuiz,
        _quizRepository = quizRepository,
        super(const QuizLibraryInitial()) {
    on<LoadQuizzesEvent>(_onLoad);
    on<SearchChangedEvent>(_onSearch);
    on<LikeQuizEvent>(_onLike);
    on<DeleteQuizEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadQuizzesEvent event,
    Emitter<QuizLibraryState> emit,
  ) async {
    emit(const QuizLibraryLoading());
    try {
      final quizzes = await _getQuizzes(
        scope: event.scope,
        search: event.search,
      );
      emit(QuizLibraryLoaded(
        quizzes: quizzes,
        scope: event.scope,
        search: event.search,
      ));
    } catch (e) {
      emit(QuizLibraryError(e.toString()));
    }
  }

  Future<void> _onSearch(
    SearchChangedEvent event,
    Emitter<QuizLibraryState> emit,
  ) async {
    final currentScope =
        state is QuizLibraryLoaded ? (state as QuizLibraryLoaded).scope : 'global';
    add(LoadQuizzesEvent(scope: currentScope, search: event.query));
  }

  Future<void> _onLike(
    LikeQuizEvent event,
    Emitter<QuizLibraryState> emit,
  ) async {
    if (state is! QuizLibraryLoaded) return;
    final loaded = state as QuizLibraryLoaded;
    try {
      final result = await _likeQuiz(event.quizId);
      final updated = loaded.quizzes.map((q) {
        if (q.id != event.quizId) return q;
        return q.copyWith(
          isLiked: result.liked,
          likesCount: result.likesCount,
        );
      }).toList();
      emit(QuizLibraryLoaded(
        quizzes: updated,
        scope: loaded.scope,
        search: loaded.search,
      ));
    } catch (_) {}
  }

  Future<void> _onDelete(
    DeleteQuizEvent event,
    Emitter<QuizLibraryState> emit,
  ) async {
    if (state is! QuizLibraryLoaded) return;
    final loaded = state as QuizLibraryLoaded;
    final optimistic = loaded.quizzes.where((q) => q.id != event.quizId).toList();
    emit(QuizLibraryLoaded(
      quizzes: optimistic,
      scope: loaded.scope,
      search: loaded.search,
    ));
    try {
      await _quizRepository.deleteQuiz(event.quizId);
    } catch (_) {
      add(LoadQuizzesEvent(scope: loaded.scope, search: loaded.search));
    }
  }
}
