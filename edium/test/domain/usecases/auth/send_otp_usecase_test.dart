import 'package:edium/domain/repositories/auth_repository.dart';
import 'package:edium/domain/usecases/auth/send_otp_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SendOtpUsecase usecase;

  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = SendOtpUsecase(mockRepo);
  });

  test('возвращает retryAfter из репозитория', () async {
    when(() => mockRepo.sendOtp(phone: '+79991234567', channel: 'sms'))
        .thenAnswer((_) async => 180);

    final result = await usecase(phone: '+79991234567', channel: 'sms');

    expect(result, 180);
    verify(() => mockRepo.sendOtp(phone: '+79991234567', channel: 'sms')).called(1);
  });

  test('пробрасывает исключение из репозитория', () async {
    when(() => mockRepo.sendOtp(phone: any(named: 'phone'), channel: any(named: 'channel')))
        .thenThrow(Exception('сеть недоступна'));

    expect(
      () => usecase(phone: '+79991234567', channel: 'tg'),
      throwsException,
    );
  });
}
