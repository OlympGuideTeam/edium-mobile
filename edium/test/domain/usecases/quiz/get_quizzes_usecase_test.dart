import 'package:edium/domain/entities/quiz.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/get_quizzes_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuizRepository extends Mock implements IQuizRepository {}

Quiz _makeQuiz(String id) => Quiz(
      id: id,
      title: 'Квиз $id',
      subject: 'Математика',
      authorId: 'user-1',
      authorName: 'Иван Иванов',
      status: QuizStatus.active,
      settings: const QuizSettings(),
      questions: const [],
      likesCount: 0,
      isLiked: false,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  late MockQuizRepository mockRepo;
  late GetQuizzesUsecase usecase;

  setUp(() {
    mockRepo = MockQuizRepository();
    usecase = GetQuizzesUsecase(mockRepo);
  });

  test('возвращает список квизов с дефолтными параметрами', () async {
    final quizzes = [_makeQuiz('q-1'), _makeQuiz('q-2')];
    when(() => mockRepo.getQuizzes(
          scope: 'global',
          search: null,
          page: 1,
          limit: 20,
        )).thenAnswer((_) async => quizzes);

    final result = await usecase();

    expect(result, quizzes);
    verify(() => mockRepo.getQuizzes(
          scope: 'global',
          search: null,
          page: 1,
          limit: 20,
        )).called(1);
  });

  test('передаёт параметры поиска и scope в репозиторий', () async {
    when(() => mockRepo.getQuizzes(
          scope: 'my',
          search: 'алгебра',
          page: 1,
          limit: 20,
        )).thenAnswer((_) async => [_makeQuiz('q-3')]);

    final result = await usecase(scope: 'my', search: 'алгебра');

    expect(result.length, 1);
    expect(result.first.id, 'q-3');
  });

  test('пробрасывает исключение из репозитория', () async {
    when(() => mockRepo.getQuizzes(
          scope: any(named: 'scope'),
          search: any(named: 'search'),
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        )).thenThrow(Exception('ошибка'));

    expect(() => usecase(), throwsException);
  });
}
