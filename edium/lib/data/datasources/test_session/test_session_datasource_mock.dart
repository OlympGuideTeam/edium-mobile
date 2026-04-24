import 'package:edium/data/datasources/test_session/test_session_datasource.dart';
import 'package:edium/data/models/attempt_review_model.dart';
import 'package:edium/data/models/attempt_summary_model.dart';
import 'package:edium/data/models/quiz_attempt_model.dart';
import 'package:edium/data/models/test_session_meta_model.dart';

class TestSessionDatasourceMock implements ITestSessionDatasource {
  // sessionId → meta
  static final Map<String, TestSessionMetaModel> _sessions = _buildSessions();
  // sessionId → questions
  static final Map<String, List<QuizQuestionForStudentModel>> _questions =
      _buildQuestions();
  // sessionId → List<attempt> (для teacher view)
  static final Map<String, List<_MockAttempt>> _attemptsBySession =
      _buildAttempts();
  // attemptId → AttemptReviewModel (для GetAttemptReview)
  static final Map<String, AttemptReviewModel> _reviews = _buildReviews();

  int _attemptCounter = 100;

  @override
  Future<TestSessionMetaModel> getSessionMetaByQuizId({
    required String quizId,
    String? fallbackSessionId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final sid = fallbackSessionId;
    if (sid != null && _sessions.containsKey(sid)) return _sessions[sid]!;
    // Fallback: по quizId ищем первую сессию с таким quiz_id
    return _sessions.values.firstWhere(
      (s) => s.quizId == quizId,
      orElse: () =>
          throw Exception('Тест не найден (mock): quizId=$quizId, sid=$sid'),
    );
  }

  @override
  Future<QuizAttemptModel> createAttempt(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_sessions.containsKey(sessionId)) {
      throw Exception('Сессия не найдена (mock): $sessionId');
    }
    final aid = 'mock-attempt-${_attemptCounter++}';
    final qs = _questions[sessionId] ?? const [];
    return QuizAttemptModel(attemptId: aid, questions: qs);
  }

  @override
  Future<void> submitAnswer({
    required String attemptId,
    required String questionId,
    required Map<String, dynamic> answerData,
  }) async {
    await Future.delayed(const Duration(milliseconds: 60));
  }

  @override
  Future<void> finishAttempt(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<AttemptSummaryModel>> listSessionAttempts(
      String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final list = _attemptsBySession[sessionId] ?? const [];
    return list
        .map((a) => AttemptSummaryModel(
              attemptId: a.attemptId,
              userId: a.userId,
              status: a.status,
              score: a.score,
            ))
        .toList();
  }

  @override
  Future<AttemptReviewModel> getAttemptReview(String attemptId) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final r = _reviews[attemptId];
    if (r == null) throw Exception('Попытка не найдена (mock): $attemptId');
    return r;
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    // Noop в мока (или можно удалить из статической карты, но state shared).
  }

  // ── Seed data ──────────────────────────────────────────────────────────

  static Map<String, TestSessionMetaModel> _buildSessions() => {
        'mock-test-sess-1': const TestSessionMetaModel(
          sessionId: 'mock-test-sess-1',
          quizId: 'quiz-uuid-0001',
          title: 'Многочлены: проверочный',
          description: 'Короткий тест по теме «Многочлены».',
          questionCount: 3,
          needEvaluation: false,
          totalTimeLimitSec: 600,
          shuffleQuestions: false,
          startedAt: null,
          finishedAt: null,
        ),
        'mock-test-sess-2': const TestSessionMetaModel(
          sessionId: 'mock-test-sess-2',
          quizId: 'quiz-uuid-0002',
          title: 'Уравнения I',
          questionCount: 2,
          needEvaluation: true,
          totalTimeLimitSec: 1200,
        ),
        'mock-test-sess-3': const TestSessionMetaModel(
          sessionId: 'mock-test-sess-3',
          quizId: 'quiz-uuid-0003',
          title: 'Функции — вводный',
          questionCount: 2,
          needEvaluation: false,
          totalTimeLimitSec: 300,
          startedAt: '2030-01-01T09:00:00Z',
          finishedAt: '2030-01-10T23:59:00Z',
        ),
      };

  static Map<String, List<QuizQuestionForStudentModel>> _buildQuestions() => {
        'mock-test-sess-1': [
          QuizQuestionForStudentModel(
            id: 'qt1-1',
            type: 'single_choice',
            text: 'Степень многочлена 3x² + 2x + 1?',
            maxScore: 10,
            options: const [
              QuestionOptionForStudentModel(id: 'qt1-1-a', text: '1'),
              QuestionOptionForStudentModel(id: 'qt1-1-b', text: '2'),
              QuestionOptionForStudentModel(id: 'qt1-1-c', text: '3'),
            ],
          ),
          const QuizQuestionForStudentModel(
            id: 'qt1-2',
            type: 'with_given_answer',
            text: 'Чему равна сумма коэффициентов 2x+3?',
            maxScore: 10,
          ),
          QuizQuestionForStudentModel(
            id: 'qt1-3',
            type: 'multiple_choice',
            text: 'Выберите многочлены (не одночлены)',
            maxScore: 10,
            options: const [
              QuestionOptionForStudentModel(id: 'qt1-3-a', text: '2x'),
              QuestionOptionForStudentModel(id: 'qt1-3-b', text: 'x²+1'),
              QuestionOptionForStudentModel(id: 'qt1-3-c', text: '5'),
              QuestionOptionForStudentModel(id: 'qt1-3-d', text: '3x+5'),
            ],
          ),
        ],
        'mock-test-sess-2': [
          const QuizQuestionForStudentModel(
            id: 'qt2-1',
            type: 'with_free_answer',
            text: 'Опишите метод решения линейного уравнения.',
            maxScore: 20,
          ),
          QuizQuestionForStudentModel(
            id: 'qt2-2',
            type: 'single_choice',
            text: 'Корень уравнения 2x+4=0?',
            maxScore: 10,
            options: const [
              QuestionOptionForStudentModel(id: 'qt2-2-a', text: '-2'),
              QuestionOptionForStudentModel(id: 'qt2-2-b', text: '2'),
              QuestionOptionForStudentModel(id: 'qt2-2-c', text: '0'),
            ],
          ),
        ],
        'mock-test-sess-3': [
          const QuizQuestionForStudentModel(
            id: 'qt3-1',
            type: 'with_given_answer',
            text: 'Значение f(x)=x²+1 при x=2?',
            maxScore: 10,
          ),
          const QuizQuestionForStudentModel(
            id: 'qt3-2',
            type: 'with_given_answer',
            text: 'Значение f(x)=2x при x=-3?',
            maxScore: 10,
          ),
        ],
      };

  static Map<String, List<_MockAttempt>> _buildAttempts() => {
        'mock-test-sess-1': [
          _MockAttempt(
            attemptId: 'mock-att-1-A',
            userId: 'mock-user-S1',
            status: 'completed',
            score: 25.0,
          ),
          _MockAttempt(
            attemptId: 'mock-att-1-B',
            userId: 'mock-user-S2',
            status: 'in_progress',
            score: null,
          ),
        ],
        'mock-test-sess-2': [
          _MockAttempt(
            attemptId: 'mock-att-2-A',
            userId: 'mock-user-S1',
            status: 'grading',
            score: null,
          ),
        ],
        'mock-test-sess-3': const [],
      };

  static Map<String, AttemptReviewModel> _buildReviews() => {
        'mock-att-1-A': AttemptReviewModel(
          attemptId: 'mock-att-1-A',
          userId: 'mock-user-S1',
          status: 'completed',
          score: 25.0,
          startedAt: '2026-04-20T10:00:00Z',
          finishedAt: '2026-04-20T10:08:00Z',
          answers: [
            AnswerReviewModel(
              submissionId: 'sub-1',
              questionId: 'qt1-1',
              questionType: 'single_choice',
              questionText: 'Степень многочлена 3x² + 2x + 1?',
              answerData: {'selected_option_id': 'qt1-1-b'},
              finalScore: 10.0,
              finalSource: 'auto',
              options: const [
                TeacherAnswerOptionModel(
                    id: 'qt1-1-a', text: '1', isCorrect: false),
                TeacherAnswerOptionModel(
                    id: 'qt1-1-b', text: '2', isCorrect: true),
                TeacherAnswerOptionModel(
                    id: 'qt1-1-c', text: '3', isCorrect: false),
              ],
            ),
            AnswerReviewModel(
              submissionId: 'sub-2',
              questionId: 'qt1-2',
              questionType: 'with_given_answer',
              questionText: 'Чему равна сумма коэффициентов 2x+3?',
              answerData: const {'text': '5'},
              finalScore: 10.0,
              finalSource: 'auto',
              metadata: const {'correct_answers': ['5']},
            ),
            AnswerReviewModel(
              submissionId: 'sub-3',
              questionId: 'qt1-3',
              questionType: 'multiple_choice',
              questionText: 'Выберите многочлены (не одночлены)',
              answerData: const {
                'selected_option_ids': ['qt1-3-b', 'qt1-3-d']
              },
              finalScore: 5.0,
              finalSource: 'auto',
              options: const [
                TeacherAnswerOptionModel(
                    id: 'qt1-3-a', text: '2x', isCorrect: false),
                TeacherAnswerOptionModel(
                    id: 'qt1-3-b', text: 'x²+1', isCorrect: true),
                TeacherAnswerOptionModel(
                    id: 'qt1-3-c', text: '5', isCorrect: false),
                TeacherAnswerOptionModel(
                    id: 'qt1-3-d', text: '3x+5', isCorrect: true),
              ],
            ),
          ],
        ),
        'mock-att-1-B': AttemptReviewModel(
          attemptId: 'mock-att-1-B',
          userId: 'mock-user-S2',
          status: 'in_progress',
          score: null,
          startedAt: '2026-04-22T10:00:00Z',
          answers: const [],
        ),
        'mock-att-2-A': AttemptReviewModel(
          attemptId: 'mock-att-2-A',
          userId: 'mock-user-S1',
          status: 'grading',
          score: null,
          startedAt: '2026-04-21T14:00:00Z',
          finishedAt: '2026-04-21T14:30:00Z',
          answers: const [
            AnswerReviewModel(
              submissionId: 'sub-10',
              questionId: 'qt2-1',
              questionType: 'with_free_answer',
              questionText: 'Опишите метод решения линейного уравнения.',
              answerData: {'text': 'Переносим x влево, свободный член вправо…'},
              finalScore: null,
              finalSource: null,
              finalFeedback: null,
            ),
            AnswerReviewModel(
              submissionId: 'sub-11',
              questionId: 'qt2-2',
              questionType: 'single_choice',
              questionText: 'Корень уравнения 2x+4=0?',
              answerData: {'selected_option_id': 'qt2-2-a'},
              finalScore: 10.0,
              finalSource: 'auto',
              options: [
                TeacherAnswerOptionModel(
                    id: 'qt2-2-a', text: '-2', isCorrect: true),
                TeacherAnswerOptionModel(
                    id: 'qt2-2-b', text: '2', isCorrect: false),
                TeacherAnswerOptionModel(
                    id: 'qt2-2-c', text: '0', isCorrect: false),
              ],
            ),
          ],
        ),
      };
}

class _MockAttempt {
  final String attemptId;
  final String userId;
  final String status;
  final double? score;

  const _MockAttempt({
    required this.attemptId,
    required this.userId,
    required this.status,
    required this.score,
  });
}
