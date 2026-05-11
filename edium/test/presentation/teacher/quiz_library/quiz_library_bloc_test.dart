import 'package:bloc_test/bloc_test.dart';
import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:edium/domain/usecases/quiz/like_quiz_usecase.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_bloc.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_event.dart';
import 'package:edium/presentation/teacher/quiz_library/bloc/quiz_library_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuizRepository extends Mock implements IQuizRepository {}

Quiz _makeQuiz(String id, {bool isLiked = false, int likesCount = 0}) => Quiz(
      id: id,
      title: 'Квиз $id',
      subject: 'Математика',
      authorId: 'user-1',
      authorName: 'Иван Иванов',
      status: QuizStatus.active,
      settings: const QuizSettings(),
      questions: const [],
      likesCount: likesCount,
      isLiked: isLiked,
      createdAt: DateTime(2026, 1, 1),
    );

QuizLibraryBloc _makeBloc(MockQuizRepository repo) => QuizLibraryBloc(
      getQuizzes: GetQuizzesUsecase(repo),
      likeQuiz: LikeQuizUsecase(repo),
      quizRepository: repo,
    );

void main() {
  late MockQuizRepository mockRepo;

  setUp(() {
    mockRepo = MockQuizRepository();
  });

  group('LoadQuizzesEvent', () {
    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'загружает квизы → эмитит Loading, Loaded',
      build: () {
        when(() => mockRepo.getQuizzes(
              scope: 'global',
              search: null,
              page: 1,
              limit: 20,
            )).thenAnswer((_) async => [_makeQuiz('q-1'), _makeQuiz('q-2')]);
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const LoadQuizzesEvent()),
      expect: () => [
        const QuizLibraryLoading(),
        isA<QuizLibraryLoaded>()
            .having((s) => s.quizzes.length, 'length', 2)
            .having((s) => s.scope, 'scope', 'global'),
      ],
    );

    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'загружает квизы с scope=my',
      build: () {
        when(() => mockRepo.getQuizzes(
              scope: 'my',
              search: null,
              page: 1,
              limit: 20,
            )).thenAnswer((_) async => [_makeQuiz('q-3')]);
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const LoadQuizzesEvent(scope: 'my')),
      expect: () => [
        const QuizLibraryLoading(),
        isA<QuizLibraryLoaded>()
            .having((s) => s.scope, 'scope', 'my')
            .having((s) => s.quizzes.length, 'length', 1),
      ],
    );

    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'при ошибке → эмитит QuizLibraryError',
      build: () {
        when(() => mockRepo.getQuizzes(
              scope: any(named: 'scope'),
              search: any(named: 'search'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenThrow(Exception('сеть'));
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const LoadQuizzesEvent()),
      expect: () => [
        const QuizLibraryLoading(),
        isA<QuizLibraryError>(),
      ],
    );
  });

  group('SearchChangedEvent', () {
    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'делегирует поиск в LoadQuizzesEvent с текущим scope',
      build: () {
        when(() => mockRepo.getQuizzes(
              scope: 'global',
              search: 'алгебра',
              page: 1,
              limit: 20,
            )).thenAnswer((_) async => [_makeQuiz('q-4')]);
        return _makeBloc(mockRepo);
      },
      seed: () => const QuizLibraryLoaded(
        quizzes: [],
        scope: 'global',
      ),
      act: (b) => b.add(const SearchChangedEvent('алгебра')),
      expect: () => [
        const QuizLibraryLoading(),
        isA<QuizLibraryLoaded>()
            .having((s) => s.search, 'search', 'алгебра')
            .having((s) => s.quizzes.length, 'length', 1),
      ],
    );
  });

  group('LikeQuizEvent', () {
    final initial = [
      _makeQuiz('q-1', isLiked: false, likesCount: 10),
      _makeQuiz('q-2', isLiked: true, likesCount: 5),
    ];

    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'обновляет isLiked и likesCount для конкретного квиза',
      build: () {
        when(() => mockRepo.likeQuiz('q-1'))
            .thenAnswer((_) async => (liked: true, likesCount: 11));
        return _makeBloc(mockRepo);
      },
      seed: () => QuizLibraryLoaded(quizzes: initial, scope: 'global'),
      act: (b) => b.add(const LikeQuizEvent('q-1')),
      expect: () => [
        isA<QuizLibraryLoaded>().having(
          (s) => s.quizzes.firstWhere((q) => q.id == 'q-1').isLiked,
          'isLiked',
          isTrue,
        ),
      ],
    );

    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'игнорируется если состояние не Loaded',
      build: () => _makeBloc(mockRepo),
      act: (b) => b.add(const LikeQuizEvent('q-1')),
      expect: () => [],
    );

    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'при ошибке лайка — состояние не меняется',
      build: () {
        when(() => mockRepo.likeQuiz(any())).thenThrow(Exception('ошибка'));
        return _makeBloc(mockRepo);
      },
      seed: () => QuizLibraryLoaded(quizzes: initial, scope: 'global'),
      act: (b) => b.add(const LikeQuizEvent('q-1')),
      expect: () => [],
    );
  });

  group('DeleteQuizEvent', () {
    final initial = [_makeQuiz('q-1'), _makeQuiz('q-2')];

    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'оптимистично удаляет квиз из списка',
      build: () {
        when(() => mockRepo.deleteQuiz('q-1')).thenAnswer((_) async {});
        return _makeBloc(mockRepo);
      },
      seed: () => QuizLibraryLoaded(quizzes: initial, scope: 'global'),
      act: (b) => b.add(const DeleteQuizEvent('q-1')),
      expect: () => [
        isA<QuizLibraryLoaded>()
            .having((s) => s.quizzes.length, 'length', 1)
            .having((s) => s.quizzes.first.id, 'id', 'q-2'),
      ],
    );

    blocTest<QuizLibraryBloc, QuizLibraryState>(
      'при ошибке сервера — перезагружает список',
      build: () {
        when(() => mockRepo.deleteQuiz('q-1')).thenThrow(Exception('ошибка'));
        when(() => mockRepo.getQuizzes(
              scope: any(named: 'scope'),
              search: any(named: 'search'),
              page: any(named: 'page'),
              limit: any(named: 'limit'),
            )).thenAnswer((_) async => initial);
        return _makeBloc(mockRepo);
      },
      seed: () => QuizLibraryLoaded(quizzes: initial, scope: 'global'),
      act: (b) => b.add(const DeleteQuizEvent('q-1')),
      expect: () => [
        // оптимистичное удаление
        isA<QuizLibraryLoaded>().having((s) => s.quizzes.length, 'length', 1),
        // перезагрузка после ошибки
        const QuizLibraryLoading(),
        isA<QuizLibraryLoaded>().having((s) => s.quizzes.length, 'length', 2),
      ],
    );
  });
}
