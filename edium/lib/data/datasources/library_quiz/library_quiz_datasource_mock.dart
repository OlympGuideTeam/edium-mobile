import 'package:edium/data/datasources/library_quiz/library_quiz_datasource.dart';
import 'package:edium/data/models/library_quiz_model.dart';
import 'package:edium/data/models/quiz_attempt_model.dart';

class LibraryQuizDatasourceMock implements ILibraryQuizDatasource {
  static final List<LibraryQuizModel> _quizzes = _buildQuizzes();

  // attemptId → (sessionId, questions, answers)
  final Map<String, _AttemptState> _attempts = {};
  int _attemptCounter = 1;

  @override
  Future<List<LibraryQuizModel>> getPublicQuizzes({String? search}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = _quizzes
        .where((q) => !q.isDraft && q.isPublic)
        .toList();
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list
          .where((quiz) =>
              quiz.title.toLowerCase().contains(q) ||
              (quiz.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }

  @override
  Future<LibraryQuizModel> getQuizForStudent(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final quiz = _quizzes.firstWhere(
      (q) => q.id == id,
      orElse: () => throw Exception('Квиз не найден'),
    );
    return quiz;
  }

  @override
  Future<QuizAttemptModel> createAttempt(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final quiz = _quizzes.firstWhere(
      (q) => q.libraryTestSessionId == sessionId,
      orElse: () => throw Exception('Сессия не найдена'),
    );
    final questions = _questionsFor(quiz.id);
    final attemptId = 'mock-attempt-${_attemptCounter++}';
    _attempts[attemptId] = _AttemptState(
      sessionId: sessionId,
      quizId: quiz.id,
      questions: questions,
      startedAt: DateTime.now(),
    );
    return QuizAttemptModel(
      attemptId: attemptId,
      questions: questions,
    );
  }

  @override
  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final state = _attempts[attemptId];
    if (state == null) throw Exception('Попытка не найдена');
    state.answers[questionId] = answerData;
  }

  @override
  Future<void> finishAttempt(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final state = _attempts[attemptId];
    if (state == null) throw Exception('Попытка не найдена');
    state.finishedAt = DateTime.now();
  }

  @override
  Future<AttemptResultModel> getAttemptResult(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final state = _attempts[attemptId];
    if (state == null) throw Exception('Попытка не найдена');

    final quiz = _quizzes.firstWhere((q) => q.id == state.quizId);
    final allQuestions = _questionsForEval(quiz.id);

    final answers = state.questions.map((q) {
      final answerData = state.answers[q.id] ?? {};
      final evalResult = _evaluate(q, answerData, allQuestions);
      return AnswerSubmissionResultModel(
        questionId: q.id,
        answerData: answerData,
        finalScore: evalResult.score,
        finalSource: evalResult.source,
        finalFeedback: evalResult.feedback,
        correctData: evalResult.correctData,
      );
    }).toList();

    final totalScore =
        answers.fold<double>(0, (s, a) => s + (a.finalScore ?? 0));

    return AttemptResultModel(
      attemptId: attemptId,
      status: 'completed',
      score: totalScore,
      startedAt: state.startedAt.toIso8601String(),
      finishedAt: (state.finishedAt ?? DateTime.now()).toIso8601String(),
      answers: answers,
    );
  }

  // ── evaluation ──────────────────────────────────────────────────────────

  _EvalResult _evaluate(
    QuizQuestionForStudentModel question,
    Map<String, dynamic> answerData,
    List<_QuizQuestionFull> allQuestions,
  ) {
    if (answerData.isEmpty) {
      return _EvalResult(score: 0, source: 'auto');
    }

    final full = allQuestions.firstWhere((q) => q.id == question.id,
        orElse: () => _QuizQuestionFull(id: question.id));

    switch (question.type) {
      case 'single_choice':
        final selected = answerData['selected_option_id'] as String?;
        final correct = full.correctOptionId;
        if (selected == null || correct == null) {
          return _EvalResult(score: 0, source: 'auto');
        }
        return selected == correct
            ? _EvalResult(score: question.maxScore.toDouble(), source: 'auto')
            : _EvalResult(
                score: 0,
                source: 'auto',
                correctData: {'correct_option_ids': [correct]},
              );

      case 'multiple_choice':
        final selected =
            (answerData['selected_option_ids'] as List<dynamic>? ?? [])
                .map((e) => e.toString())
                .toSet();
        final correct = full.correctOptionIds;
        if (correct.isEmpty) return _EvalResult(score: 0, source: 'auto');
        final correctHit = selected.intersection(correct).length;
        final wrongHit = selected.difference(correct).length;
        final ratio = (correctHit - wrongHit) / correct.length;
        return _EvalResult(
          score: (ratio.clamp(0.0, 1.0) * question.maxScore).roundToDouble(),
          source: 'auto',
          correctData: {'correct_option_ids': correct.toList()},
        );

      case 'with_given_answer':
        final text =
            answerData['text']?.toString().trim().toLowerCase() ?? '';
        final correctAnswers =
            (full.correctAnswers ?? []).map((a) => a.trim().toLowerCase());
        return correctAnswers.contains(text)
            ? _EvalResult(
                score: question.maxScore.toDouble(),
                source: 'auto',
                correctData: {'correct_answers': full.correctAnswers ?? []},
              )
            : _EvalResult(
                score: 0,
                source: 'auto',
                correctData: {'correct_answers': full.correctAnswers ?? []},
              );

      case 'with_free_answer':
        return _EvalResult(
          score: (question.maxScore * 0.7).roundToDouble(),
          source: 'llm',
          feedback: 'Ответ засчитан (демо-оценка ИИ)',
        );

      case 'drag':
        final order = (answerData['order'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList();
        final correctOrder = full.correctOrder ?? [];
        return order.join(',') == correctOrder.join(',')
            ? _EvalResult(score: question.maxScore.toDouble(), source: 'auto')
            : _EvalResult(
                score: 0,
                source: 'auto',
                correctData: {'correct_order': correctOrder},
              );

      case 'connection':
        final pairs = (answerData['pairs'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, v.toString()));
        final correctPairs = full.correctPairs ?? {};
        final allCorrect = correctPairs.entries.every(
          (e) => pairs[e.key] == e.value,
        );
        return allCorrect
            ? _EvalResult(score: question.maxScore.toDouble(), source: 'auto')
            : _EvalResult(
                score: 0,
                source: 'auto',
                correctData: {'correct_pairs': correctPairs},
              );

      default:
        return _EvalResult(score: 0, source: 'auto');
    }
  }

  // ── seed data ────────────────────────────────────────────────────────────

  static final _now = DateTime(2026, 4, 20, 14, 0);

  static List<LibraryQuizModel> _buildQuizzes() => [
        LibraryQuizModel(
          id: 'quiz-001',
          title: 'Основы Dart',
          description:
              'Проверь знания синтаксиса и базовых концепций языка Dart.',
          defaultSettings: const QuizDefaultSettingsModel(
            totalTimeLimitSec: 300,
            shuffleQuestions: false,
          ),
          isPublic: true,
          isDraft: false,
          needEvaluation: false,
          questionCount: 4,
          libraryTestSessionId: 'lib-session-001',
          attempts: [
            QuizAttemptSummaryModel(
              id: 'attempt-001',
              sessionId: 'lib-session-001',
              sessionType: 'test',
              status: 'published',
              score: 7.5,
              startedAt: _now.subtract(const Duration(days: 5)).toIso8601String(),
              finishedAt: _now.subtract(const Duration(days: 5, minutes: -4)).toIso8601String(),
            ),
          ],
        ),
        LibraryQuizModel(
          id: 'quiz-002',
          title: 'Flutter Widgets',
          description: 'Статeless, Stateful и базовые виджеты Flutter.',
          defaultSettings: const QuizDefaultSettingsModel(
            shuffleQuestions: true,
          ),
          isPublic: true,
          isDraft: false,
          needEvaluation: false,
          questionCount: 3,
          libraryTestSessionId: 'lib-session-002',
          attempts: [
            QuizAttemptSummaryModel(
              id: 'attempt-002',
              sessionId: 'lib-session-002',
              sessionType: 'test',
              status: 'published',
              score: 10.0,
              startedAt: _now.subtract(const Duration(days: 2)).toIso8601String(),
              finishedAt: _now.subtract(const Duration(days: 2, minutes: -3)).toIso8601String(),
            ),
          ],
        ),
        LibraryQuizModel(
          id: 'quiz-003',
          title: 'История России',
          description: null,
          defaultSettings: const QuizDefaultSettingsModel(
            totalTimeLimitSec: 600,
          ),
          isPublic: true,
          isDraft: false,
          needEvaluation: true,
          questionCount: 4,
          libraryTestSessionId: 'lib-session-003',
        ),
        LibraryQuizModel(
          id: 'quiz-004',
          title: 'Логика и алгоритмы',
          description: 'Задачи на последовательности и сопоставление.',
          defaultSettings: const QuizDefaultSettingsModel(),
          isPublic: true,
          isDraft: false,
          needEvaluation: false,
          questionCount: 2,
          libraryTestSessionId: 'lib-session-004',
        ),
      ];

  List<QuizQuestionForStudentModel> _questionsFor(String quizId) {
    switch (quizId) {
      case 'quiz-001':
        return [
          QuizQuestionForStudentModel(
            id: 'q001-1',
            type: 'single_choice',
            text: 'Какой тип является nullable в Dart?',
            maxScore: 10,
            options: [
              const QuestionOptionForStudentModel(
                  id: 'q001-1-a', text: 'int'),
              const QuestionOptionForStudentModel(
                  id: 'q001-1-b', text: 'int?'),
              const QuestionOptionForStudentModel(
                  id: 'q001-1-c', text: 'String'),
              const QuestionOptionForStudentModel(
                  id: 'q001-1-d', text: 'dynamic'),
            ],
          ),
          QuizQuestionForStudentModel(
            id: 'q001-2',
            type: 'multiple_choice',
            text: 'Какие из коллекций неизменяемы в Dart?',
            maxScore: 10,
            options: [
              const QuestionOptionForStudentModel(
                  id: 'q001-2-a', text: 'List'),
              const QuestionOptionForStudentModel(
                  id: 'q001-2-b', text: 'const List'),
              const QuestionOptionForStudentModel(
                  id: 'q001-2-c', text: 'const Set'),
              const QuestionOptionForStudentModel(
                  id: 'q001-2-d', text: 'Map'),
            ],
          ),
          const QuizQuestionForStudentModel(
            id: 'q001-3',
            type: 'with_given_answer',
            text: 'Напишите ключевое слово для асинхронной функции в Dart.',
            maxScore: 10,
          ),
          const QuizQuestionForStudentModel(
            id: 'q001-4',
            type: 'with_free_answer',
            text:
                'Объясните разницу между final и const в Dart.',
            maxScore: 10,
          ),
        ];

      case 'quiz-002':
        return [
          QuizQuestionForStudentModel(
            id: 'q002-1',
            type: 'single_choice',
            text: 'Какой виджет НЕ хранит состояние?',
            maxScore: 10,
            options: [
              const QuestionOptionForStudentModel(
                  id: 'q002-1-a', text: 'StatelessWidget'),
              const QuestionOptionForStudentModel(
                  id: 'q002-1-b', text: 'StatefulWidget'),
              const QuestionOptionForStudentModel(
                  id: 'q002-1-c', text: 'InheritedWidget'),
              const QuestionOptionForStudentModel(
                  id: 'q002-1-d', text: 'ChangeNotifier'),
            ],
          ),
          QuizQuestionForStudentModel(
            id: 'q002-2',
            type: 'multiple_choice',
            text: 'Какие виджеты используются для раскладки в строку?',
            maxScore: 10,
            options: [
              const QuestionOptionForStudentModel(
                  id: 'q002-2-a', text: 'Row'),
              const QuestionOptionForStudentModel(
                  id: 'q002-2-b', text: 'Column'),
              const QuestionOptionForStudentModel(
                  id: 'q002-2-c', text: 'Wrap'),
              const QuestionOptionForStudentModel(
                  id: 'q002-2-d', text: 'Stack'),
            ],
          ),
          QuizQuestionForStudentModel(
            id: 'q002-3',
            type: 'single_choice',
            text: 'Метод setState() вызывается в…',
            maxScore: 10,
            options: [
              const QuestionOptionForStudentModel(
                  id: 'q002-3-a', text: 'StatelessWidget'),
              const QuestionOptionForStudentModel(
                  id: 'q002-3-b', text: 'State<T>'),
              const QuestionOptionForStudentModel(
                  id: 'q002-3-c', text: 'BuildContext'),
              const QuestionOptionForStudentModel(
                  id: 'q002-3-d', text: 'Widget'),
            ],
          ),
        ];

      case 'quiz-003':
        return [
          QuizQuestionForStudentModel(
            id: 'q003-1',
            type: 'single_choice',
            text: 'В каком году произошла Куликовская битва?',
            maxScore: 10,
            options: [
              const QuestionOptionForStudentModel(
                  id: 'q003-1-a', text: '1380'),
              const QuestionOptionForStudentModel(
                  id: 'q003-1-b', text: '1242'),
              const QuestionOptionForStudentModel(
                  id: 'q003-1-c', text: '1480'),
              const QuestionOptionForStudentModel(
                  id: 'q003-1-d', text: '1612'),
            ],
          ),
          const QuizQuestionForStudentModel(
            id: 'q003-2',
            type: 'with_given_answer',
            text: 'Как называлось первое государство восточных славян?',
            maxScore: 10,
          ),
          const QuizQuestionForStudentModel(
            id: 'q003-3',
            type: 'with_free_answer',
            text: 'Опишите значение реформ Петра I для развития России.',
            maxScore: 10,
          ),
          QuizQuestionForStudentModel(
            id: 'q003-4',
            type: 'multiple_choice',
            text: 'Какие события относятся к Смутному времени?',
            maxScore: 10,
            options: [
              const QuestionOptionForStudentModel(
                  id: 'q003-4-a', text: 'Самозванцы'),
              const QuestionOptionForStudentModel(
                  id: 'q003-4-b', text: 'Крещение Руси'),
              const QuestionOptionForStudentModel(
                  id: 'q003-4-c', text: 'Польская интервенция'),
              const QuestionOptionForStudentModel(
                  id: 'q003-4-d', text: 'Опричнина'),
            ],
          ),
        ];

      case 'quiz-004':
        return [
          QuizQuestionForStudentModel(
            id: 'q004-1',
            type: 'drag',
            text: 'Расставьте этапы разработки в правильном порядке:',
            maxScore: 10,
            metadata: const {
              'items': ['Тестирование', 'Дизайн', 'Требования', 'Разработка'],
              'correct_order': ['Требования', 'Дизайн', 'Разработка', 'Тестирование'],
            },
          ),
          QuizQuestionForStudentModel(
            id: 'q004-2',
            type: 'connection',
            text: 'Сопоставьте концепцию с её определением:',
            maxScore: 10,
            metadata: const {
              'left': ['Инкапсуляция', 'Наследование', 'Полиморфизм'],
              'right': [
                'Переопределение методов',
                'Скрытие данных',
                'Расширение класса',
              ],
              'correct_pairs': {
                'Инкапсуляция': 'Скрытие данных',
                'Наследование': 'Расширение класса',
                'Полиморфизм': 'Переопределение методов',
              },
            },
          ),
        ];

      default:
        return [];
    }
  }

  List<_QuizQuestionFull> _questionsForEval(String quizId) {
    switch (quizId) {
      case 'quiz-001':
        return [
          _QuizQuestionFull(id: 'q001-1', correctOptionId: 'q001-1-b'),
          _QuizQuestionFull(
              id: 'q001-2',
              correctOptionIds: {'q001-2-b', 'q001-2-c'}),
          _QuizQuestionFull(
              id: 'q001-3', correctAnswers: ['async', 'async*']),
          _QuizQuestionFull(id: 'q001-4'), // free answer
        ];
      case 'quiz-002':
        return [
          _QuizQuestionFull(id: 'q002-1', correctOptionId: 'q002-1-a'),
          _QuizQuestionFull(
              id: 'q002-2',
              correctOptionIds: {'q002-2-a', 'q002-2-c'}),
          _QuizQuestionFull(id: 'q002-3', correctOptionId: 'q002-3-b'),
        ];
      case 'quiz-003':
        return [
          _QuizQuestionFull(id: 'q003-1', correctOptionId: 'q003-1-a'),
          _QuizQuestionFull(
              id: 'q003-2',
              correctAnswers: [
                'киевская русь',
                'русь',
                'киевская русь',
                'kievan rus',
              ]),
          _QuizQuestionFull(id: 'q003-3'), // free
          _QuizQuestionFull(
              id: 'q003-4',
              correctOptionIds: {'q003-4-a', 'q003-4-c'}),
        ];
      case 'quiz-004':
        return [
          _QuizQuestionFull(
              id: 'q004-1',
              correctOrder: [
                'Требования',
                'Дизайн',
                'Разработка',
                'Тестирование',
              ]),
          _QuizQuestionFull(
              id: 'q004-2',
              correctPairs: {
                'Инкапсуляция': 'Скрытие данных',
                'Наследование': 'Расширение класса',
                'Полиморфизм': 'Переопределение методов',
              }),
        ];
      default:
        return [];
    }
  }
}

class _AttemptState {
  final String sessionId;
  final String quizId;
  final List<QuizQuestionForStudentModel> questions;
  final Map<String, Map<String, dynamic>> answers = {};
  final DateTime startedAt;
  DateTime? finishedAt;

  _AttemptState({
    required this.sessionId,
    required this.quizId,
    required this.questions,
    required this.startedAt,
  });
}

class _QuizQuestionFull {
  final String id;
  final String? correctOptionId;
  final Set<String> correctOptionIds;
  final List<String>? correctAnswers;
  final List<String>? correctOrder;
  final Map<String, String>? correctPairs;

  _QuizQuestionFull({
    required this.id,
    this.correctOptionId,
    Set<String>? correctOptionIds,
    this.correctAnswers,
    this.correctOrder,
    this.correctPairs,
  }) : correctOptionIds = correctOptionIds ?? {};
}

class _EvalResult {
  final double score;
  final String source;
  final String? feedback;
  final Map<String, dynamic>? correctData;

  _EvalResult({
    required this.score,
    required this.source,
    this.feedback,
    this.correctData,
  });
}
