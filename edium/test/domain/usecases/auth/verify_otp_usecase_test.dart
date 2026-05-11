import 'package:edium/domain/repositories/auth_repository.dart';
import 'package:edium/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late VerifyOtpUsecase usecase;

  setUp(() {
    mockRepo = MockAuthRepository();
    usecase = VerifyOtpUsecase(mockRepo);
  });

  test('возвращает true для нового пользователя', () async {
    when(() => mockRepo.verifyOtp(phone: '+79991234567', otp: '123456'))
        .thenAnswer((_) async => true);

    final result = await usecase(phone: '+79991234567', otp: '123456');

    expect(result, isTrue);
  });

  test('возвращает false для существующего пользователя', () async {
    when(() => mockRepo.verifyOtp(phone: '+79991234567', otp: '654321'))
        .thenAnswer((_) async => false);

    final result = await usecase(phone: '+79991234567', otp: '654321');

    expect(result, isFalse);
  });

  test('пробрасывает исключение при неверном коде', () async {
    when(() => mockRepo.verifyOtp(phone: any(named: 'phone'), otp: any(named: 'otp')))
        .thenThrow(Exception('OTP_INVALID'));

    expect(
      () => usecase(phone: '+79991234567', otp: '000000'),
      throwsException,
    );
  });
}
