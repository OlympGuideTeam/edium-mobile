import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/usecases/class/create_class_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClassRepository extends Mock implements IClassRepository {}

void main() {
  late MockClassRepository mockRepo;
  late CreateClassUsecase usecase;

  setUp(() {
    mockRepo = MockClassRepository();
    usecase = CreateClassUsecase(mockRepo);
  });

  test('возвращает id созданного класса', () async {
    when(() => mockRepo.createClass(title: '10А — Математика'))
        .thenAnswer((_) async => 'cls-new-1');

    final id = await usecase(title: '10А — Математика');

    expect(id, 'cls-new-1');
    verify(() => mockRepo.createClass(title: '10А — Математика')).called(1);
  });

  test('пробрасывает исключение из репозитория', () async {
    when(() => mockRepo.createClass(title: any(named: 'title')))
        .thenThrow(Exception('Ошибка создания'));

    expect(() => usecase(title: 'Тестовый класс'), throwsException);
  });
}
