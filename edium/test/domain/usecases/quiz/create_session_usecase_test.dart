import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuizRepository extends Mock implements IQuizRepository {}

void main() {
  late MockQuizRepository mockRepo;
  late CreateSessionUsecase usecase;

  setUp(() {
    mockRepo = MockQuizRepository();
    usecase = CreateSessionUsecase(mockRepo);
  });

  group('SessionType.test', () {
    test('вызывает createTestSession с корректными параметрами', () async {
      when(() => mockRepo.createTestSession(
            quizTemplateId: 'tmpl-1',
            moduleId: 'mod-1',
            totalTimeLimitSec: 3600,
            shuffleQuestions: true,
            startedAt: null,
            finishedAt: null,
          )).thenAnswer((_) async => 'sess-test-1');

      final id = await usecase(
        quizTemplateId: 'tmpl-1',
        moduleId: 'mod-1',
        sessionType: SessionType.test,
        totalTimeLimitSec: 3600,
        shuffleQuestions: true,
      );

      expect(id, 'sess-test-1');
      verify(() => mockRepo.createTestSession(
            quizTemplateId: 'tmpl-1',
            moduleId: 'mod-1',
            totalTimeLimitSec: 3600,
            shuffleQuestions: true,
            startedAt: null,
            finishedAt: null,
          )).called(1);
      verifyNever(() => mockRepo.createLiveSession(
            quizTemplateId: any(named: 'quizTemplateId'),
            moduleId: any(named: 'moduleId'),
            questionTimeLimitSec: any(named: 'questionTimeLimitSec'),
          ));
    });

    test('передаёт startedAt / finishedAt в createTestSession', () async {
      final start = DateTime(2026, 9, 1);
      final finish = DateTime(2026, 9, 30);
      when(() => mockRepo.createTestSession(
            quizTemplateId: any(named: 'quizTemplateId'),
            moduleId: any(named: 'moduleId'),
            totalTimeLimitSec: any(named: 'totalTimeLimitSec'),
            shuffleQuestions: any(named: 'shuffleQuestions'),
            startedAt: start,
            finishedAt: finish,
          )).thenAnswer((_) async => 'sess-2');

      await usecase(
        quizTemplateId: 'tmpl-1',
        moduleId: 'mod-1',
        sessionType: SessionType.test,
        startedAt: start,
        finishedAt: finish,
      );

      verify(() => mockRepo.createTestSession(
            quizTemplateId: any(named: 'quizTemplateId'),
            moduleId: any(named: 'moduleId'),
            totalTimeLimitSec: any(named: 'totalTimeLimitSec'),
            shuffleQuestions: any(named: 'shuffleQuestions'),
            startedAt: start,
            finishedAt: finish,
          )).called(1);
    });
  });

  group('SessionType.live', () {
    test('вызывает createLiveSession, НЕ createTestSession', () async {
      when(() => mockRepo.createLiveSession(
            quizTemplateId: 'tmpl-1',
            moduleId: 'mod-1',
            questionTimeLimitSec: 30,
          )).thenAnswer((_) async => 'sess-live-1');

      final id = await usecase(
        quizTemplateId: 'tmpl-1',
        moduleId: 'mod-1',
        sessionType: SessionType.live,
        questionTimeLimitSec: 30,
      );

      expect(id, 'sess-live-1');
      verify(() => mockRepo.createLiveSession(
            quizTemplateId: 'tmpl-1',
            moduleId: 'mod-1',
            questionTimeLimitSec: 30,
          )).called(1);
      verifyNever(() => mockRepo.createTestSession(
            quizTemplateId: any(named: 'quizTemplateId'),
            moduleId: any(named: 'moduleId'),
            totalTimeLimitSec: any(named: 'totalTimeLimitSec'),
            shuffleQuestions: any(named: 'shuffleQuestions'),
            startedAt: any(named: 'startedAt'),
            finishedAt: any(named: 'finishedAt'),
          ));
    });
  });

  group('Обработка ошибок', () {
    test('пробрасывает исключение из createTestSession', () async {
      when(() => mockRepo.createTestSession(
            quizTemplateId: any(named: 'quizTemplateId'),
            moduleId: any(named: 'moduleId'),
            totalTimeLimitSec: any(named: 'totalTimeLimitSec'),
            shuffleQuestions: any(named: 'shuffleQuestions'),
            startedAt: any(named: 'startedAt'),
            finishedAt: any(named: 'finishedAt'),
          )).thenThrow(Exception('ошибка'));

      expect(
        () => usecase(
          quizTemplateId: 'tmpl-1',
          moduleId: 'mod-1',
          sessionType: SessionType.test,
        ),
        throwsException,
      );
    });

    test('пробрасывает исключение из createLiveSession', () async {
      when(() => mockRepo.createLiveSession(
            quizTemplateId: any(named: 'quizTemplateId'),
            moduleId: any(named: 'moduleId'),
            questionTimeLimitSec: any(named: 'questionTimeLimitSec'),
          )).thenThrow(Exception('ошибка'));

      expect(
        () => usecase(
          quizTemplateId: 'tmpl-1',
          moduleId: 'mod-1',
          sessionType: SessionType.live,
        ),
        throwsException,
      );
    });
  });
}
