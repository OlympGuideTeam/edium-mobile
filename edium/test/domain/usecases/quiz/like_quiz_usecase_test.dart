import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/like_quiz_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuizRepository extends Mock implements IQuizRepository {}

void main() {
  late MockQuizRepository mockRepo;
  late LikeQuizUsecase usecase;

  setUp(() {
    mockRepo = MockQuizRepository();
    usecase = LikeQuizUsecase(mockRepo);
  });

  test('возвращает liked=true и обновлённый счётчик лайков', () async {
    when(() => mockRepo.likeQuiz('q-1'))
        .thenAnswer((_) async => (liked: true, likesCount: 42));

    final result = await usecase('q-1');

    expect(result.liked, isTrue);
    expect(result.likesCount, 42);
    verify(() => mockRepo.likeQuiz('q-1')).called(1);
  });

  test('возвращает liked=false при снятии лайка', () async {
    when(() => mockRepo.likeQuiz('q-2'))
        .thenAnswer((_) async => (liked: false, likesCount: 5));

    final result = await usecase('q-2');

    expect(result.liked, isFalse);
    expect(result.likesCount, 5);
  });

  test('пробрасывает исключение из репозитория', () async {
    when(() => mockRepo.likeQuiz(any())).thenThrow(Exception('ошибка'));

    expect(() => usecase('q-1'), throwsException);
  });
}
