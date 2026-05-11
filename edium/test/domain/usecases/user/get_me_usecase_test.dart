import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/repositories/user_repository.dart';
import 'package:edium/domain/usecases/user/get_me_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements IUserRepository {}

const _fakeUser = User(
  id: 'user-1',
  name: 'Иван',
  surname: 'Иванов',
  phone: '+79991234567',
  role: UserRole.teacher,
);

void main() {
  late MockUserRepository mockRepo;
  late GetMeUsecase usecase;

  setUp(() {
    mockRepo = MockUserRepository();
    usecase = GetMeUsecase(mockRepo);
  });

  test('возвращает текущего пользователя', () async {
    when(() => mockRepo.getMe()).thenAnswer((_) async => _fakeUser);

    final result = await usecase();

    expect(result, _fakeUser);
    verify(() => mockRepo.getMe()).called(1);
  });

  test('пробрасывает исключение при ошибке сети', () async {
    when(() => mockRepo.getMe()).thenThrow(Exception('401'));

    expect(() => usecase(), throwsException);
  });
}
