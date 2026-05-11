import 'package:edium/domain/repositories/auth_repository.dart';
import 'package:edium/domain/usecases/auth/register_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late RegisterUsecase usecase;

  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = RegisterUsecase(mockRepo);
  });

  test('вызывает register с корректными параметрами', () async {
    when(() => mockRepo.register(
          phone: '+79991234567',
          name: 'Иван',
          surname: 'Иванов',
        )).thenAnswer((_) async {});

    await usecase(phone: '+79991234567', name: 'Иван', surname: 'Иванов');

    verify(() => mockRepo.register(
          phone: '+79991234567',
          name: 'Иван',
          surname: 'Иванов',
        )).called(1);
  });

  test('пробрасывает исключение из репозитория', () async {
    when(() => mockRepo.register(
          phone: any(named: 'phone'),
          name: any(named: 'name'),
          surname: any(named: 'surname'),
        )).thenThrow(Exception('ошибка регистрации'));

    expect(
      () => usecase(phone: '+79991234567', name: 'Иван', surname: 'Иванов'),
      throwsException,
    );
  });
}
