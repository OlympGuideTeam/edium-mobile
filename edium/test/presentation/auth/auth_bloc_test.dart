import 'package:bloc_test/bloc_test.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/repositories/auth_repository.dart';
import 'package:edium/domain/repositories/user_repository.dart';
import 'package:edium/domain/usecases/auth/logout_usecase.dart';
import 'package:edium/domain/usecases/auth/register_usecase.dart';
import 'package:edium/domain/usecases/auth/send_otp_usecase.dart';
import 'package:edium/domain/usecases/auth/verify_otp_usecase.dart';
import 'package:edium/domain/usecases/user/get_me_usecase.dart';
import 'package:edium/presentation/auth/bloc/auth_bloc.dart';
import 'package:edium/presentation/auth/bloc/auth_event.dart';
import 'package:edium/presentation/auth/bloc/auth_state.dart';
import 'package:edium/services/herald_api_service/herald_api_service_interface.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:edium/services/network/dio_handler.dart';
import 'package:edium/services/notification_service/deep_link_service.dart';
import 'package:edium/services/notification_service/notification_service.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

class MockUserRepository extends Mock implements IUserRepository {}

class MockDioHandler extends Mock implements DioHandler {}

class MockProfileStorage extends Mock implements ProfileStorage {}

class MockNotificationService extends Mock implements NotificationService {}

class MockHeraldApiService extends Mock implements IHeraldApiService {}

class MockDeepLinkService extends Mock implements DeepLinkService {}

const _fakeUser = User(
  id: 'user-1',
  name: 'Иван',
  surname: 'Иванов',
  phone: '+79991234567',
);

AuthBloc _makeBloc({
  required MockAuthRepository authRepo,
  required MockUserRepository userRepo,
  required MockDioHandler dioHandler,
  required MockProfileStorage profileStorage,
  required MockNotificationService notificationService,
  required MockHeraldApiService heraldApiService,
  required MockDeepLinkService deepLinkService,
}) {
  return AuthBloc(
    sendOtp: SendOtpUsecase(authRepo),
    verifyOtp: VerifyOtpUsecase(authRepo),
    register: RegisterUsecase(authRepo),
    logout: LogoutUsecase(authRepo),
    getMe: GetMeUsecase(userRepo),
    profileStorage: profileStorage,
    dioHandler: dioHandler,
    notificationService: notificationService,
    heraldApiService: heraldApiService,
    deepLinkService: deepLinkService,
  );
}

void main() {
  late MockAuthRepository authRepo;
  late MockUserRepository userRepo;
  late MockDioHandler dioHandler;
  late MockProfileStorage profileStorage;
  late MockNotificationService notificationService;
  late MockHeraldApiService heraldApiService;
  late MockDeepLinkService deepLinkService;

  setUp(() {
    authRepo = MockAuthRepository();
    userRepo = MockUserRepository();
    dioHandler = MockDioHandler();
    profileStorage = MockProfileStorage();
    notificationService = MockNotificationService();
    heraldApiService = MockHeraldApiService();
    deepLinkService = MockDeepLinkService();

    // FCM-регистрация — fire-and-forget, заглушаем чтобы не мешала тестам
    when(() => profileStorage.hasAskedNotificationPermission).thenReturn(true);
    when(() => notificationService.getToken()).thenAnswer((_) async => null);
    when(() => dioHandler.stopProactiveRefresh()).thenReturn(null);
    when(() => dioHandler.startProactiveRefresh()).thenReturn(null);
  });

  group('SendOtpEvent', () {
    blocTest<AuthBloc, AuthState>(
      'TG-канал → мгновенно AuthOtpSent без вызова сети',
      build: () => _makeBloc(
        authRepo: authRepo,
        userRepo: userRepo,
        dioHandler: dioHandler,
        profileStorage: profileStorage,
        notificationService: notificationService,
        heraldApiService: heraldApiService,
        deepLinkService: deepLinkService,
      ),
      act: (b) => b.add(const SendOtpEvent('+79991234567', channel: 'tg')),
      expect: () => [
        isA<AuthOtpSent>()
            .having((s) => s.phone, 'phone', '+79991234567')
            .having((s) => s.channel, 'channel', 'tg'),
      ],
      verify: (_) => verifyNever(() => authRepo.sendOtp(
            phone: any(named: 'phone'),
            channel: any(named: 'channel'),
          )),
    );

    blocTest<AuthBloc, AuthState>(
      'SMS-канал → Loading, AuthOtpSent',
      build: () {
        when(() => authRepo.sendOtp(phone: '+79991234567', channel: 'sms'))
            .thenAnswer((_) async => 180);
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) => b.add(const SendOtpEvent('+79991234567', channel: 'sms')),
      expect: () => [
        const AuthLoading(),
        isA<AuthOtpSent>().having((s) => s.retryAfter, 'retryAfter', 180),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'OTP_ALREADY_SENT → AuthOtpSent с retryAfter из деталей ошибки',
      build: () {
        when(() => authRepo.sendOtp(
              phone: any(named: 'phone'),
              channel: any(named: 'channel'),
            )).thenThrow(const ApiException(
          'Код уже отправлен',
          code: 'OTP_ALREADY_SENT',
          details: {'retry_after': 120},
        ));
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) => b.add(const SendOtpEvent('+79991234567', channel: 'sms')),
      expect: () => [
        const AuthLoading(),
        isA<AuthOtpSent>().having((s) => s.retryAfter, 'retryAfter', 120),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'сетевая ошибка → AuthError',
      build: () {
        when(() => authRepo.sendOtp(
              phone: any(named: 'phone'),
              channel: any(named: 'channel'),
            )).thenThrow(Exception('сеть'));
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) => b.add(const SendOtpEvent('+79991234567', channel: 'sms')),
      expect: () => [const AuthLoading(), isA<AuthError>()],
    );
  });

  group('VerifyOtpEvent', () {
    blocTest<AuthBloc, AuthState>(
      'новый пользователь → AuthNameRequired',
      build: () {
        when(() => authRepo.verifyOtp(phone: '+79991234567', otp: '123456'))
            .thenAnswer((_) async => true);
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) =>
          b.add(const VerifyOtpEvent(phone: '+79991234567', otp: '123456')),
      expect: () => [
        const AuthLoading(),
        isA<AuthNameRequired>()
            .having((s) => s.phone, 'phone', '+79991234567'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'существующий пользователь без сохранённой роли → AuthRoleRequired',
      build: () {
        when(() => authRepo.verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => false);
        when(() => dioHandler.syncTokenFromStorage()).thenAnswer((_) async {});
        when(() => profileStorage.savePhone(any())).thenAnswer((_) async {});
        when(() => userRepo.getMe()).thenAnswer((_) async => _fakeUser);
        when(() => profileStorage.saveName(any())).thenAnswer((_) async {});
        when(() => profileStorage.getRole()).thenReturn(null);
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) =>
          b.add(const VerifyOtpEvent(phone: '+79991234567', otp: '654321')),
      expect: () => [
        const AuthLoading(),
        isA<AuthRoleRequired>().having((s) => s.user, 'user', _fakeUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'существующий пользователь с сохранённой ролью teacher → AuthAuthenticated',
      build: () {
        when(() => authRepo.verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => false);
        when(() => dioHandler.syncTokenFromStorage()).thenAnswer((_) async {});
        when(() => profileStorage.savePhone(any())).thenAnswer((_) async {});
        when(() => userRepo.getMe()).thenAnswer((_) async => _fakeUser);
        when(() => profileStorage.saveName(any())).thenAnswer((_) async {});
        when(() => profileStorage.getRole()).thenReturn('teacher');
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) =>
          b.add(const VerifyOtpEvent(phone: '+79991234567', otp: '654321')),
      expect: () => [
        const AuthLoading(),
        isA<AuthAuthenticated>()
            .having((s) => s.user.role, 'role', UserRole.teacher),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'ошибка верификации → AuthError',
      build: () {
        when(() => authRepo.verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
            )).thenThrow(Exception('OTP_INVALID'));
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) =>
          b.add(const VerifyOtpEvent(phone: '+79991234567', otp: '000000')),
      expect: () => [const AuthLoading(), isA<AuthError>()],
    );
  });

  group('RegisterEvent', () {
    blocTest<AuthBloc, AuthState>(
      'успешная регистрация → AuthRoleRequired',
      build: () {
        when(() => authRepo.register(
              phone: any(named: 'phone'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
            )).thenAnswer((_) async {});
        when(() => dioHandler.syncTokenFromStorage()).thenAnswer((_) async {});
        when(() => profileStorage.savePhone(any())).thenAnswer((_) async {});
        when(() => profileStorage.saveName(any())).thenAnswer((_) async {});
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) => b.add(const RegisterEvent(
        phone: '+79991234567',
        name: 'Иван',
        surname: 'Иванов',
      )),
      expect: () => [
        const AuthLoading(),
        isA<AuthRoleRequired>()
            .having((s) => s.user.name, 'name', 'Иван'),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'ошибка регистрации → AuthError',
      build: () {
        when(() => authRepo.register(
              phone: any(named: 'phone'),
              name: any(named: 'name'),
              surname: any(named: 'surname'),
            )).thenThrow(Exception('ошибка'));
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) => b.add(const RegisterEvent(
        phone: '+79991234567',
        name: 'Иван',
        surname: 'Иванов',
      )),
      expect: () => [const AuthLoading(), isA<AuthError>()],
    );
  });

  group('LogoutEvent', () {
    blocTest<AuthBloc, AuthState>(
      'выход → AuthUnauthenticated',
      build: () {
        when(() => authRepo.logout()).thenAnswer((_) async {});
        when(() => profileStorage.clear()).thenAnswer((_) async {});
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) => b.add(const LogoutEvent()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
      verify: (_) {
        verify(() => profileStorage.clear()).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'ошибка при logout → всё равно AuthUnauthenticated',
      build: () {
        when(() => authRepo.logout()).thenThrow(Exception('сеть'));
        when(() => profileStorage.clear()).thenAnswer((_) async {});
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      act: (b) => b.add(const LogoutEvent()),
      expect: () => [const AuthLoading(), const AuthUnauthenticated()],
    );
  });

  group('SessionExpiredEvent', () {
    blocTest<AuthBloc, AuthState>(
      'истёкшая сессия → AuthUnauthenticated',
      build: () => _makeBloc(
        authRepo: authRepo,
        userRepo: userRepo,
        dioHandler: dioHandler,
        profileStorage: profileStorage,
        notificationService: notificationService,
        heraldApiService: heraldApiService,
        deepLinkService: deepLinkService,
      ),
      act: (b) => b.add(const SessionExpiredEvent()),
      expect: () => [const AuthUnauthenticated()],
    );
  });

  group('SwitchToRoleEvent', () {
    blocTest<AuthBloc, AuthState>(
      'переключение на student → обновляет роль пользователя',
      build: () {
        when(() => profileStorage.saveRole(any())).thenAnswer((_) async {});
        return _makeBloc(
          authRepo: authRepo,
          userRepo: userRepo,
          dioHandler: dioHandler,
          profileStorage: profileStorage,
          notificationService: notificationService,
          heraldApiService: heraldApiService,
          deepLinkService: deepLinkService,
        );
      },
      seed: () => const AuthAuthenticated(
          User(id: 'u-1', name: 'Иван', phone: '+7', role: UserRole.teacher)),
      act: (b) => b.add(const SwitchToRoleEvent('student')),
      expect: () => [
        isA<AuthAuthenticated>()
            .having((s) => s.user.role, 'role', UserRole.student),
      ],
      verify: (_) => verify(() => profileStorage.saveRole('student')).called(1),
    );

    blocTest<AuthBloc, AuthState>(
      'SwitchToRole в не-Authenticated состоянии → игнорируется',
      build: () => _makeBloc(
        authRepo: authRepo,
        userRepo: userRepo,
        dioHandler: dioHandler,
        profileStorage: profileStorage,
        notificationService: notificationService,
        heraldApiService: heraldApiService,
        deepLinkService: deepLinkService,
      ),
      act: (b) => b.add(const SwitchToRoleEvent('student')),
      expect: () => [],
    );
  });
}
