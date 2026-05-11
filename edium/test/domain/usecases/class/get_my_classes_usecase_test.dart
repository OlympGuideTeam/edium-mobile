import 'package:edium/domain/entities/class_summary.dart';
import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/usecases/class/get_my_classes_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClassRepository extends Mock implements IClassRepository {}

final _fakeClasses = [
  const ClassSummary(
    id: 'cls-1',
    title: '10А — Математика',
    ownerName: 'Пётр Сидоров',
    studentCount: 28,
    isOwner: true,
  ),
  const ClassSummary(
    id: 'cls-2',
    title: '9Б — Физика',
    ownerName: 'Анна Смирнова',
    studentCount: 25,
    isOwner: false,
  ),
];

void main() {
  late MockClassRepository mockRepo;
  late GetMyClassesUsecase usecase;

  setUp(() {
    mockRepo = MockClassRepository();
    usecase = GetMyClassesUsecase(mockRepo);
  });

  test('возвращает список классов для роли teacher', () async {
    when(() => mockRepo.getMyClasses(role: 'teacher'))
        .thenAnswer((_) async => _fakeClasses);

    final result = await usecase(role: 'teacher');

    expect(result, _fakeClasses);
    verify(() => mockRepo.getMyClasses(role: 'teacher')).called(1);
  });

  test('возвращает пустой список если классов нет', () async {
    when(() => mockRepo.getMyClasses(role: 'student'))
        .thenAnswer((_) async => []);

    final result = await usecase(role: 'student');

    expect(result, isEmpty);
  });

  test('пробрасывает исключение из репозитория', () async {
    when(() => mockRepo.getMyClasses(role: any(named: 'role')))
        .thenThrow(Exception('ошибка сети'));

    expect(() => usecase(role: 'teacher'), throwsException);
  });
}
