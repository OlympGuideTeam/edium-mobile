import 'package:bloc_test/bloc_test.dart';
import 'package:edium/domain/repositories/quiz_repository.dart';
import 'package:edium/domain/usecases/quiz/create_quiz_usecase.dart';
import 'package:edium/domain/usecases/quiz/create_session_usecase.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_bloc.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_event.dart';
import 'package:edium/presentation/teacher/create_quiz/bloc/create_quiz_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockQuizRepository extends Mock implements IQuizRepository {}

final _q1 = {'type': 'single_choice', 'text': 'Вопрос 1', 'options': []};
final _q2 = {'type': 'single_choice', 'text': 'Вопрос 2', 'options': []};

CreateQuizBloc _makeBloc(
  MockQuizRepository repo, {
  bool inCourseContext = false,
}) =>
    CreateQuizBloc(
      CreateQuizUsecase(repo),
      CreateSessionUsecase(repo),
      repo,
      inCourseContext: inCourseContext,
    );

void main() {
  late MockQuizRepository mockRepo;

  setUp(() {
    mockRepo = MockQuizRepository();
  });

  group('Мутации состояния', () {
    blocTest<CreateQuizBloc, CreateQuizState>(
      'UpdateTitleEvent → обновляет title',
      build: () => _makeBloc(mockRepo),
      act: (b) => b.add(const UpdateTitleEvent('Новый квиз')),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.title, 'title', 'Новый квиз'),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'UpdateDescriptionEvent → обновляет description',
      build: () => _makeBloc(mockRepo),
      act: (b) => b.add(const UpdateDescriptionEvent('Описание')),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.description, 'description', 'Описание'),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'UpdateTotalTimeLimitEvent с значением → устанавливает totalTimeLimitSec',
      build: () => _makeBloc(mockRepo),
      act: (b) => b.add(const UpdateTotalTimeLimitEvent(3600)),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.totalTimeLimitSec, 'totalTimeLimitSec', 3600),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'UpdateTotalTimeLimitEvent с null → очищает totalTimeLimitSec',
      build: () => _makeBloc(mockRepo),
      seed: () => const CreateQuizState(totalTimeLimitSec: 3600),
      act: (b) => b.add(const UpdateTotalTimeLimitEvent(null)),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.totalTimeLimitSec, 'totalTimeLimitSec', isNull),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'UpdateShuffleQuestionsEvent → обновляет shuffleQuestions',
      build: () => _makeBloc(mockRepo),
      act: (b) => b.add(const UpdateShuffleQuestionsEvent(true)),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.shuffleQuestions, 'shuffle', true),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'SetQuizTypeEvent → меняет quizType',
      build: () => _makeBloc(mockRepo),
      act: (b) => b.add(const SetQuizTypeEvent(QuizCreationMode.live)),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.quizType, 'quizType', QuizCreationMode.live),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'AddQuestionEvent → добавляет вопрос в список',
      build: () => _makeBloc(mockRepo),
      act: (b) => b.add(AddQuestionEvent(_q1)),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.questions.length, 'questions', 1),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'RemoveQuestionEvent → удаляет вопрос по индексу',
      build: () => _makeBloc(mockRepo),
      seed: () => CreateQuizState(questions: [_q1, _q2]),
      act: (b) => b.add(const RemoveQuestionEvent(0)),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.questions.length, 'questions', 1)
            .having((s) => s.questions.first['text'], 'text', 'Вопрос 2'),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'ReplaceQuestionEvent → заменяет вопрос по индексу',
      build: () => _makeBloc(mockRepo),
      seed: () => CreateQuizState(questions: [_q1]),
      act: (b) => b.add(ReplaceQuestionEvent(0, _q2)),
      expect: () => [
        isA<CreateQuizState>()
            .having((s) => s.questions.first['text'], 'text', 'Вопрос 2'),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'ResetCreateQuizEvent → возвращает начальное состояние',
      build: () => _makeBloc(mockRepo),
      seed: () => CreateQuizState(
        title: 'Заполненный квиз',
        questions: [_q1],
        quizType: QuizCreationMode.live,
      ),
      act: (b) => b.add(const ResetCreateQuizEvent()),
      expect: () => [const CreateQuizState()],
    );
  });

  group('canSave / canPublish', () {
    test('canSave false при пустом title', () {
      expect(const CreateQuizState(title: '').canSave, isFalse);
    });

    test('canSave true при непустом title', () {
      expect(const CreateQuizState(title: 'Квиз').canSave, isTrue);
    });

    test('canPublish false при непустом title но пустых вопросах', () {
      expect(const CreateQuizState(title: 'Квиз', questions: []).canPublish, isFalse);
    });

    test('canPublish true при title и вопросах', () {
      final state = CreateQuizState(title: 'Квиз', questions: [_q1]);
      expect(state.canPublish, isTrue);
    });
  });

  group('SubmitQuizEvent — шаблон (не курс-контекст)', () {
    blocTest<CreateQuizBloc, CreateQuizState>(
      'создаёт шаблон через createQuiz → success',
      build: () {
        when(() => mockRepo.createQuiz(
              title: any(named: 'title'),
              description: any(named: 'description'),
              mode: any(named: 'mode'),
              totalTimeLimitSec: any(named: 'totalTimeLimitSec'),
              questionTimeLimitSec: any(named: 'questionTimeLimitSec'),
              shuffleQuestions: any(named: 'shuffleQuestions'),
              startedAt: any(named: 'startedAt'),
              finishedAt: any(named: 'finishedAt'),
              questions: any(named: 'questions'),
              courseId: any(named: 'courseId'),
            )).thenAnswer((_) async => 'quiz-new-1');
        return _makeBloc(mockRepo);
      },
      seed: () => CreateQuizState(title: 'Квиз', questions: [_q1]),
      act: (b) => b.add(const SubmitQuizEvent()),
      expect: () => [
        isA<CreateQuizState>().having((s) => s.isSubmitting, 'submitting', true),
        isA<CreateQuizState>()
            .having((s) => s.success, 'success', true)
            .having((s) => s.isSubmitting, 'submitting', false),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'canPublish=false → не запускает создание',
      build: () => _makeBloc(mockRepo),
      seed: () => const CreateQuizState(title: ''),
      act: (b) => b.add(const SubmitQuizEvent()),
      expect: () => [],
      verify: (_) => verifyNever(() => mockRepo.createQuiz(
            title: any(named: 'title'),
            description: any(named: 'description'),
            mode: any(named: 'mode'),
            totalTimeLimitSec: any(named: 'totalTimeLimitSec'),
            questionTimeLimitSec: any(named: 'questionTimeLimitSec'),
            shuffleQuestions: any(named: 'shuffleQuestions'),
            startedAt: any(named: 'startedAt'),
            finishedAt: any(named: 'finishedAt'),
            questions: any(named: 'questions'),
            courseId: any(named: 'courseId'),
          )),
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'ошибка при создании → error в состоянии',
      build: () {
        when(() => mockRepo.createQuiz(
              title: any(named: 'title'),
              description: any(named: 'description'),
              mode: any(named: 'mode'),
              totalTimeLimitSec: any(named: 'totalTimeLimitSec'),
              questionTimeLimitSec: any(named: 'questionTimeLimitSec'),
              shuffleQuestions: any(named: 'shuffleQuestions'),
              startedAt: any(named: 'startedAt'),
              finishedAt: any(named: 'finishedAt'),
              questions: any(named: 'questions'),
              courseId: any(named: 'courseId'),
            )).thenThrow(Exception('ошибка'));
        return _makeBloc(mockRepo);
      },
      seed: () => CreateQuizState(title: 'Квиз', questions: [_q1]),
      act: (b) => b.add(const SubmitQuizEvent()),
      expect: () => [
        isA<CreateQuizState>().having((s) => s.isSubmitting, 'submitting', true),
        isA<CreateQuizState>().having((s) => s.error, 'error', isNotNull),
      ],
    );
  });

  group('SubmitQuizEvent — курс-контекст test', () {
    blocTest<CreateQuizBloc, CreateQuizState>(
      'создаёт test-сессию через createTestSessionInline',
      build: () {
        when(() => mockRepo.createTestSessionInline(
              title: any(named: 'title'),
              description: any(named: 'description'),
              courseId: any(named: 'courseId'),
              moduleId: any(named: 'moduleId'),
              questions: any(named: 'questions'),
              totalTimeLimitSec: any(named: 'totalTimeLimitSec'),
              shuffleQuestions: any(named: 'shuffleQuestions'),
              startedAt: any(named: 'startedAt'),
              finishedAt: any(named: 'finishedAt'),
            )).thenAnswer((_) async => 'sess-1');
        return _makeBloc(mockRepo, inCourseContext: true);
      },
      seed: () => CreateQuizState(
        title: 'Тест',
        questions: [_q1],
        quizType: QuizCreationMode.test,
        isInCourseContext: true,
      ),
      act: (b) => b.add(
        const SubmitQuizEvent(courseId: 'course-1', moduleId: 'mod-1'),
      ),
      expect: () => [
        isA<CreateQuizState>().having((s) => s.isSubmitting, 'submitting', true),
        isA<CreateQuizState>()
            .having((s) => s.success, 'success', true)
            .having((s) => s.submittedModuleId, 'moduleId', 'mod-1'),
      ],
    );

    blocTest<CreateQuizBloc, CreateQuizState>(
      'создаёт live-сессию через createLiveSessionInline → liveSessionId в состоянии',
      build: () {
        when(() => mockRepo.createLiveSessionInline(
              title: any(named: 'title'),
              description: any(named: 'description'),
              courseId: any(named: 'courseId'),
              moduleId: any(named: 'moduleId'),
              questions: any(named: 'questions'),
              questionTimeLimitSec: any(named: 'questionTimeLimitSec'),
            )).thenAnswer((_) async => 'live-sess-1');
        return _makeBloc(mockRepo, inCourseContext: true);
      },
      seed: () => CreateQuizState(
        title: 'Лайв',
        questions: [_q1],
        quizType: QuizCreationMode.live,
        isInCourseContext: true,
      ),
      act: (b) => b.add(
        const SubmitQuizEvent(courseId: 'course-1', moduleId: 'mod-1'),
      ),
      expect: () => [
        isA<CreateQuizState>().having((s) => s.isSubmitting, 'submitting', true),
        isA<CreateQuizState>()
            .having((s) => s.liveSessionId, 'liveSessionId', 'live-sess-1'),
      ],
    );
  });
}
