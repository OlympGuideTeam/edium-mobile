import 'package:bloc_test/bloc_test.dart';
import 'package:edium/domain/entities/user.dart';
import 'package:edium/domain/entities/user_statistic.dart';
import 'package:edium/domain/repositories/user_repository.dart';
import 'package:edium/domain/usecases/user/get_me_usecase.dart';
import 'package:edium/domain/usecases/user/get_user_statistic_usecase.dart';
import 'package:edium/presentation/profile/bloc/profile_bloc.dart';
import 'package:edium/presentation/profile/bloc/profile_event.dart';
import 'package:edium/presentation/profile/bloc/profile_state.dart';
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

const _fakeStatistic = UserStatistic(
  classTeacherCount: 3,
  studentCount: 45,
  courseTeacherCount: 7,
  courseStudentCount: 5,
  quizCountPassed: 20,
  avgQuizScore: 78.5,
  quizSessionsConducted: 12,
);

const _zeroStatistic = UserStatistic(
  classTeacherCount: 0,
  studentCount: 0,
  courseTeacherCount: 0,
  courseStudentCount: 0,
  quizCountPassed: 0,
  avgQuizScore: 0,
  quizSessionsConducted: 0,
);

ProfileBloc _makeBloc(MockUserRepository repo) => ProfileBloc(
      getMe: GetMeUsecase(repo),
      getStatistic: GetUserStatisticUsecase(repo),
    );

void main() {
  late MockUserRepository mockRepo;

  setUp(() {
    mockRepo = MockUserRepository();
  });

  group('LoadProfileEvent', () {
    blocTest<ProfileBloc, ProfileState>(
      'загружает пользователя и статистику → эмитит Loading, Loaded',
      build: () {
        when(() => mockRepo.getMe()).thenAnswer((_) async => _fakeUser);
        when(() => mockRepo.getStatistic())
            .thenAnswer((_) async => _fakeStatistic);
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const LoadProfileEvent()),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileLoaded>()
            .having((s) => s.user.id, 'user.id', 'user-1')
            .having((s) => s.statistic.avgQuizScore, 'avgQuizScore', 78.5),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'при ошибке статистики — использует нулевую статистику, не падает',
      build: () {
        when(() => mockRepo.getMe()).thenAnswer((_) async => _fakeUser);
        when(() => mockRepo.getStatistic()).thenThrow(Exception('ошибка'));
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const LoadProfileEvent()),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileLoaded>()
            .having((s) => s.user, 'user', _fakeUser)
            .having(
              (s) => s.statistic.classTeacherCount,
              'classTeacherCount',
              0,
            ),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'при ошибке getMe → эмитит ProfileError',
      build: () {
        when(() => mockRepo.getMe()).thenThrow(Exception('401'));
        return _makeBloc(mockRepo);
      },
      act: (b) => b.add(const LoadProfileEvent()),
      expect: () => [
        const ProfileLoading(),
        isA<ProfileError>(),
      ],
    );

    blocTest<ProfileBloc, ProfileState>(
      'повторная загрузка при уже Loaded — не эмитит Loading',
      build: () {
        when(() => mockRepo.getMe()).thenAnswer((_) async => _fakeUser);
        when(() => mockRepo.getStatistic())
            .thenAnswer((_) async => _fakeStatistic);
        return _makeBloc(mockRepo);
      },
      seed: () =>
          const ProfileLoaded(user: _fakeUser, statistic: _zeroStatistic),
      act: (b) => b.add(const LoadProfileEvent()),
      expect: () => [
        isA<ProfileLoaded>(),
      ],
    );
  });
}
