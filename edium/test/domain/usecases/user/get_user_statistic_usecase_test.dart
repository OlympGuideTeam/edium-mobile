import 'package:edium/domain/entities/user_statistic.dart';
import 'package:edium/domain/repositories/user_repository.dart';
import 'package:edium/domain/usecases/user/get_user_statistic_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements IUserRepository {}

const _fakeStatistic = UserStatistic(
  classTeacherCount: 3,
  studentCount: 45,
  courseTeacherCount: 7,
  courseStudentCount: 5,
  quizCountPassed: 20,
  avgQuizScore: 78.5,
  quizSessionsConducted: 12,
);

void main() {
  late MockUserRepository mockRepo;
  late GetUserStatisticUsecase usecase;

  setUp(() {
    mockRepo = MockUserRepository();
    usecase = GetUserStatisticUsecase(mockRepo);
  });

  test('возвращает статистику пользователя', () async {
    when(() => mockRepo.getStatistic()).thenAnswer((_) async => _fakeStatistic);

    final result = await usecase();

    expect(result.classTeacherCount, 3);
    expect(result.avgQuizScore, 78.5);
    verify(() => mockRepo.getStatistic()).called(1);
  });

  test('пробрасывает исключение при ошибке', () async {
    when(() => mockRepo.getStatistic()).thenThrow(Exception('ошибка'));

    expect(() => usecase(), throwsException);
  });
}
