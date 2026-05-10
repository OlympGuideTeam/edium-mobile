import 'package:edium/data/datasources/quiz_session/quiz_session_datasource.dart';
import 'package:edium/data/models/quiz_session_model.dart';


class QuizSessionDatasourceMock implements IQuizSessionDatasource {
  final List<QuizSessionModel> _sessions = [];
  int _nextId = 1;


  final Map<String, dynamic> _correctAnswers = {
    'q1': 'b',
    'q2': ['a', 'b'],
    'q3': '7',
    'q4': 'b',
    'q5': ['a', 'b', 'd'],
    'q6': 'c',
  };

  bool _isCorrect(String questionId, dynamic answer) {
    final correct = _correctAnswers[questionId];
    if (correct == null) return true;
    if (correct is List) {
      if (answer is List) {
        final correctSet = Set.from(correct);
        final answerSet = Set.from(answer);
        return correctSet.length == answerSet.length &&
            correctSet.containsAll(answerSet);
      }
      return false;
    }
    return answer.toString() == correct.toString();
  }

  @override
  Future<QuizSessionModel> startSession(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final session = QuizSessionModel(
      id: 'session-${_nextId++}',
      quizId: quizId,
      userId: 'mock-user-1',
      status: 'in_progress',
      answers: [],
      startedAt: DateTime.now().toIso8601String(),
    );
    _sessions.add(session);
    return session;
  }

  @override
  Future<QuizSessionModel> getSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _sessions.firstWhere((s) => s.id == sessionId);
  }

  @override
  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final correct = _isCorrect(questionId, answer);
    const explanations = <String, String>{
      'q1': 'Дискриминант D = 25 - 24 = 1 > 0, значит два корня.',
      'q2': 'x² = 4, x = ±2',
      'q3': 'По теореме Виета: сумма корней = 7',
      'q4': 'Манифест Александра II об отмене крепостного права — 1861 год.',
      'q5': 'В XIX веке правили Александр I, Николай I, Александр II, Александр III.',
      'q6': 'Бинарный поиск — O(log n).',
    };
    final explanation = correct ? null : explanations[questionId];


    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    if (idx != -1) {
      final session = _sessions[idx];
      final updatedAnswers = [
        ...session.answers,
        AnswerRecordModel(
          questionId: questionId,
          answer: answer,
          correct: correct,
          explanation: explanation,
        ),
      ];
      _sessions[idx] = QuizSessionModel(
        id: session.id,
        quizId: session.quizId,
        userId: session.userId,
        status: session.status,
        answers: updatedAnswers,
        score: session.score,
        totalQuestions: session.totalQuestions,
        startedAt: session.startedAt,
        completedAt: session.completedAt,
      );
    }

    return {
      'correct': correct,
      'explanation': explanation,
    };
  }

  @override
  Future<QuizSessionModel> completeSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _sessions.indexWhere((s) => s.id == sessionId);
    final session = _sessions[idx];
    final score = session.answers.where((a) => a.correct == true).length;
    final completed = QuizSessionModel(
      id: session.id,
      quizId: session.quizId,
      userId: session.userId,
      status: 'completed',
      answers: session.answers,
      score: score,
      totalQuestions: session.answers.length,
      startedAt: session.startedAt,
      completedAt: DateTime.now().toIso8601String(),
    );
    _sessions[idx] = completed;
    return completed;
  }

  @override
  Future<List<QuizSessionModel>> getMySessions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _sessions.where((s) => s.userId == 'mock-user-1').toList();
  }
}
