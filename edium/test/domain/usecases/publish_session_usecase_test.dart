import 'package:edium/domain/repositories/test_session_repository.dart';
import 'package:edium/domain/usecases/test_session/publish_session_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTestSessionRepository extends Mock implements ITestSessionRepository {}

void main() {
  late MockTestSessionRepository mockRepo;
  late PublishSessionUsecase usecase;

  setUp(() {
    mockRepo = MockTestSessionRepository();
    usecase = PublishSessionUsecase(mockRepo);
  });

  test('вызывает publishSession репозитория', () async {
    when(() => mockRepo.publishSession('session-1'))
        .thenAnswer((_) async {});

    await usecase('session-1');

    verify(() => mockRepo.publishSession('session-1')).called(1);
  });
}
