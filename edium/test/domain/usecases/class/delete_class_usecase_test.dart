import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/usecases/class/delete_class_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockClassRepository extends Mock implements IClassRepository {}

void main() {
  late MockClassRepository mockRepo;
  late DeleteClassUsecase usecase;

  setUp(() {
    mockRepo = MockClassRepository();
    usecase = DeleteClassUsecase(mockRepo);
  });

  test('вызывает deleteClass с корректным classId', () async {
    when(() => mockRepo.deleteClass(classId: 'cls-1'))
        .thenAnswer((_) async {});

    await usecase(classId: 'cls-1');

    verify(() => mockRepo.deleteClass(classId: 'cls-1')).called(1);
  });

  test('пробрасывает исключение из репозитория', () async {
    when(() => mockRepo.deleteClass(classId: any(named: 'classId')))
        .thenThrow(Exception('Нет прав'));

    expect(() => usecase(classId: 'cls-1'), throwsException);
  });
}
