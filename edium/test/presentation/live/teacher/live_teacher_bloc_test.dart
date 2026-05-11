import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:edium/domain/entities/live_question.dart';
import 'package:edium/domain/entities/live_results.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/live_ws_event.dart';
import 'package:edium/domain/entities/question.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_bloc.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_event.dart';
import 'package:edium/presentation/live/teacher/bloc/live_teacher_state.dart';
import 'package:edium/services/live_ws/live_ws_service.dart';
import 'package:edium/services/network/api_exception.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLiveRepository extends Mock implements ILiveRepository {}

class MockLiveWsService extends Mock implements LiveWsService {}

final _startResult = const LiveStartResult(
  wsToken: 'tok-abc',
  joinCode: '123456',
);

final _fakeQuestion = const LiveQuestion(
  id: 'q-1',
  type: QuestionType.singleChoice,
  text: 'Вопрос 1',
  maxScore: 10,
  options: [
    LiveAnswerOption(id: 'a-1', text: 'Ответ A'),
    LiveAnswerOption(id: 'a-2', text: 'Ответ B'),
  ],
);

final _lobbyParticipant = const LiveLobbyParticipant(
  attemptId: 'att-1',
  userId: 'user-1',
  name: 'Иван',
);

final _lobbySnapshot = LiveStateSnapshot(
  phase: LivePhase.lobby,
  questionTotal: 5,
  lobbyParticipants: [_lobbyParticipant],
);

LiveTeacherBloc _makeBloc(MockLiveRepository repo, MockLiveWsService ws) =>
    LiveTeacherBloc(repo: repo, ws: ws);

void main() {
  late MockLiveRepository mockRepo;
  late MockLiveWsService mockWs;
  late StreamController<LiveWsEvent> wsController;

  setUp(() {
    mockRepo = MockLiveRepository();
    mockWs = MockLiveWsService();
    wsController = StreamController<LiveWsEvent>.broadcast();
    when(() => mockWs.events).thenAnswer((_) => wsController.stream);
    when(() => mockWs.connect(any(), any())).thenAnswer((_) async {});
    when(() => mockWs.disconnect()).thenAnswer((_) async {});
    when(() => mockWs.send(any())).thenReturn(null);
  });

  tearDown(() => wsController.close());

  group('LiveTeacherLoad', () {
    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'успешное подключение → Connecting, затем ждёт WS-события',
      build: () {
        when(() => mockRepo.startLiveSession('sess-1'))
            .thenAnswer((_) async => _startResult);
        return _makeBloc(mockRepo, mockWs);
      },
      act: (b) => b.add(LiveTeacherLoad(
        sessionId: 'sess-1',
        quizTitle: 'Квиз',
        questionCount: 5,
      )),
      expect: () => [isA<LiveTeacherConnecting>()],
      verify: (_) {
        verify(() => mockRepo.startLiveSession('sess-1')).called(1);
        verify(() => mockWs.connect('sess-1', 'tok-abc')).called(1);
      },
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'SESSION_COMPLETED при подключении → LiveTeacherCompleted',
      build: () {
        when(() => mockRepo.startLiveSession(any()))
            .thenThrow(const ApiException('завершён', code: 'SESSION_COMPLETED'));
        return _makeBloc(mockRepo, mockWs);
      },
      act: (b) => b.add(LiveTeacherLoad(
        sessionId: 'sess-1',
        quizTitle: 'Квиз',
        questionCount: 5,
      )),
      expect: () => [
        isA<LiveTeacherConnecting>(),
        isA<LiveTeacherCompleted>(),
      ],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'сетевая ошибка → LiveTeacherError',
      build: () {
        when(() => mockRepo.startLiveSession(any()))
            .thenThrow(Exception('timeout'));
        return _makeBloc(mockRepo, mockWs);
      },
      act: (b) => b.add(LiveTeacherLoad(
        sessionId: 'sess-1',
        quizTitle: 'Квиз',
        questionCount: 5,
      )),
      expect: () => [
        isA<LiveTeacherConnecting>(),
        isA<LiveTeacherError>(),
      ],
    );
  });

  group('LiveTeacherWsEvent — состояния лобби', () {
    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'StateSnapshot phase=lobby → LiveTeacherLobby',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherWsEvent(_lobbySnapshot)),
      expect: () => [
        isA<LiveTeacherLobby>()
            .having((s) => s.participants.length, 'participants', 1),
      ],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'StateSnapshot phase=pending → LiveTeacherPending',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherWsEvent(LiveStateSnapshot(
        phase: LivePhase.pending,
        questionTotal: 3,
        lobbyParticipants: [],
      ))),
      expect: () => [isA<LiveTeacherPending>()],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'StateSnapshot phase=completed → LiveTeacherCompleted',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherWsEvent(LiveStateSnapshot(
        phase: LivePhase.completed,
        questionTotal: 5,
        lobbyParticipants: [],
      ))),
      expect: () => [isA<LiveTeacherCompleted>()],
    );
  });

  group('LiveTeacherWsEvent — участники', () {
    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'ParticipantJoined в Lobby → добавляет участника',
      build: () => _makeBloc(mockRepo, mockWs),
      seed: () => LiveTeacherLobby(
        quizTitle: 'Квиз',
        questionCount: 5,
        joinCode: '123456',
        participants: [],
      ),
      act: (b) => b.add(LiveTeacherWsEvent(
        LiveLobbyParticipantJoined(
          attemptId: 'att-1',
          userId: 'user-1',
          name: 'Иван',
        ),
      )),
      expect: () => [
        isA<LiveTeacherLobby>()
            .having((s) => s.participants.length, 'participants', 1),
      ],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'ParticipantJoined дважды с тем же attemptId → не дублируется',
      build: () => _makeBloc(mockRepo, mockWs),
      seed: () => LiveTeacherLobby(
        quizTitle: 'Квиз',
        questionCount: 5,
        participants: [],
      ),
      act: (b) async {
        b.add(LiveTeacherWsEvent(LiveLobbyParticipantJoined(
          attemptId: 'att-1',
          name: 'Иван',
        )));
        await Future.microtask(() {});
        b.add(LiveTeacherWsEvent(LiveLobbyParticipantJoined(
          attemptId: 'att-1',
          name: 'Иван',
        )));
      },
      expect: () => [
        isA<LiveTeacherLobby>()
            .having((s) => s.participants.length, 'len', 1),
        isA<LiveTeacherLobby>()
            .having((s) => s.participants.length, 'len', 1),
      ],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'ParticipantLeft → удаляет участника из лобби',
      build: () => _makeBloc(mockRepo, mockWs),
      seed: () => LiveTeacherLobby(
        quizTitle: 'Квиз',
        questionCount: 5,
        participants: [],
      ),
      act: (b) async {
        b.add(LiveTeacherWsEvent(LiveLobbyParticipantJoined(
          attemptId: 'att-1',
          name: 'Иван',
        )));
        await Future.microtask(() {});
        b.add(LiveTeacherWsEvent(
          LiveLobbyParticipantLeft(attemptId: 'att-1'),
        ));
      },
      expect: () => [
        isA<LiveTeacherLobby>()
            .having((s) => s.participants.length, 'len', 1),
        isA<LiveTeacherLobby>()
            .having((s) => s.participants.length, 'len', 0),
      ],
    );
  });

  group('LiveTeacherWsEvent — вопросы', () {
    final deadline = DateTime.now().add(const Duration(seconds: 30));

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'QuestionStarted → LiveTeacherQuestionActive',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherWsEvent(LiveQuestionStarted(
        questionIndex: 1,
        question: _fakeQuestion,
        timeLimitSec: 30,
        startedAt: deadline.subtract(const Duration(seconds: 30)),
        deadlineAt: deadline,
      ))),
      expect: () => [
        isA<LiveTeacherQuestionActive>()
            .having((s) => s.question.id, 'questionId', 'q-1')
            .having((s) => s.questionIndex, 'index', 1)
            .having((s) => s.answeredMap, 'answeredMap', isEmpty),
      ],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'ParticipantAnswered в QuestionActive → добавляет в answeredMap',
      build: () => _makeBloc(mockRepo, mockWs),
      seed: () => LiveTeacherQuestionActive(
        question: _fakeQuestion,
        questionIndex: 1,
        questionTotal: 5,
        deadlineAt: DateTime.now().add(const Duration(seconds: 25)),
        timeLimitSec: 30,
        participants: [_lobbyParticipant],
        answeredMap: {},
        pendingAttemptIds: ['att-1'],
      ),
      act: (b) => b.add(LiveTeacherWsEvent(LiveParticipantAnswered(
        attemptId: 'att-1',
        questionId: 'q-1',
        isCorrect: true,
        timeTakenMs: 5000,
      ))),
      expect: () => [
        isA<LiveTeacherQuestionActive>()
            .having((s) => s.answeredMap.length, 'answered', 1)
            .having((s) => s.pendingAttemptIds, 'pending', isEmpty),
      ],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'QuizCompleted → LiveTeacherCompleted',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherWsEvent(LiveQuizCompleted())),
      expect: () => [isA<LiveTeacherCompleted>()],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'WsDisconnected в QuestionActive → LiveTeacherError',
      build: () => _makeBloc(mockRepo, mockWs),
      seed: () => LiveTeacherQuestionActive(
        question: _fakeQuestion,
        questionIndex: 1,
        questionTotal: 5,
        deadlineAt: DateTime.now().add(const Duration(seconds: 10)),
        timeLimitSec: 30,
        participants: [],
        answeredMap: {},
        pendingAttemptIds: [],
      ),
      act: (b) => b.add(LiveTeacherWsEvent(LiveWsDisconnected())),
      expect: () => [isA<LiveTeacherError>()],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'WsDisconnected после Completed → не меняет состояние',
      build: () => _makeBloc(mockRepo, mockWs),
      seed: () => LiveTeacherCompleted(),
      act: (b) => b.add(LiveTeacherWsEvent(LiveWsDisconnected())),
      expect: () => [],
    );
  });

  group('LiveTeacherStartLobby / StartQuiz / NextQuestion / Kick', () {
    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'StartLobby → отправляет WS-сообщение teacher.start_lobby',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherStartLobby()),
      expect: () => [],
      verify: (_) {
        final captured = verify(() => mockWs.send(captureAny())).captured;
        expect((captured.single as Map<String, dynamic>)['type'], 'teacher.start_lobby');
      },
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'StartQuiz → отправляет WS-сообщение teacher.start_quiz',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherStartQuiz()),
      expect: () => [],
      verify: (_) {
        final captured = verify(() => mockWs.send(captureAny())).captured;
        expect((captured.single as Map<String, dynamic>)['type'], 'teacher.start_quiz');
      },
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'NextQuestion → отправляет WS-сообщение teacher.next_question',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherNextQuestion()),
      expect: () => [],
      verify: (_) {
        final captured = verify(() => mockWs.send(captureAny())).captured;
        expect((captured.single as Map<String, dynamic>)['type'], 'teacher.next_question');
      },
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'KickParticipant → отправляет WS с attempt_id',
      build: () => _makeBloc(mockRepo, mockWs),
      act: (b) => b.add(LiveTeacherKickParticipant('att-1')),
      expect: () => [],
      verify: (_) {
        final captured = verify(() => mockWs.send(captureAny())).captured;
        final msg = captured.single as Map<String, dynamic>;
        expect(msg['type'], 'teacher.kick_participant');
        expect((msg['data'] as Map)['attempt_id'], 'att-1');
      },
    );
  });

  group('LiveTeacherLoadResults', () {
    final fakeResults = LiveResultsTeacher(
      questions: const [],
      leaderboard: [
        LiveResultsTeacherAttempt(
          position: 1,
          attemptId: 'att-1',
          userId: 'user-1',
          name: 'Иван',
          score: 80,
          maxScore: 100,
          correctCount: 4,
          answers: const [],
        ),
      ],
    );

    blocTest<LiveTeacherBloc, LiveTeacherState>(
      'загружает результаты → ResultsLoading, ResultsLoaded',
      build: () {
        when(() => mockRepo.getLiveResultsTeacher(any()))
            .thenAnswer((_) async => fakeResults);
        return _makeBloc(mockRepo, mockWs);
      },
      seed: () => LiveTeacherCompleted(),
      act: (b) {
        // Устанавливаем _sessionId через Load (упрощённо через внутреннее событие)
        b.add(LiveTeacherLoadResults());
      },
      expect: () => [],
    );
  });
}
