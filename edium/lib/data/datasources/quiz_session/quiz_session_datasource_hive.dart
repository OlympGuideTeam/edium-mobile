import 'dart:convert';

import 'package:edium/core/storage/hive_storage.dart';
import 'package:edium/data/datasources/quiz_session/quiz_session_datasource.dart';
import 'package:edium/data/models/quiz_model.dart';
import 'package:edium/data/models/quiz_session_model.dart';

class QuizSessionDatasourceHive implements IQuizSessionDatasource {
  int _nextId = 1;

  QuizSessionDatasourceHive() {
    // Determine next ID from existing sessions
    for (final key in HiveStorage.sessionsBox.keys) {
      final raw = key.toString();
      if (raw.startsWith('session-')) {
        final num = int.tryParse(raw.replaceFirst('session-', '')) ?? 0;
        if (num >= _nextId) _nextId = num + 1;
      }
    }
  }

  QuizModel? _findQuiz(String quizId) {
    final raw = HiveStorage.quizzesBox.get(quizId);
    if (raw == null) return null;
    try {
      return QuizModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  QuizSessionModel? _readSession(String sessionId) {
    final raw = HiveStorage.sessionsBox.get(sessionId);
    if (raw == null) return null;
    try {
      return QuizSessionModel.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveSession(QuizSessionModel session) async {
    await HiveStorage.sessionsBox
        .put(session.id, jsonEncode(_sessionToJson(session)));
  }

  Map<String, dynamic> _sessionToJson(QuizSessionModel s) => {
        'id': s.id,
        'quiz_id': s.quizId,
        'user_id': s.userId,
        'status': s.status,
        'answers': s.answers
            .map((a) => {
                  'question_id': a.questionId,
                  'answer': a.answer,
                  if (a.correct != null) 'correct': a.correct,
                  if (a.explanation != null) 'explanation': a.explanation,
                })
            .toList(),
        if (s.score != null) 'score': s.score,
        if (s.totalQuestions != null) 'total_questions': s.totalQuestions,
        'started_at': s.startedAt,
        if (s.completedAt != null) 'completed_at': s.completedAt,
      };

  bool _evaluateAnswer(QuizModel quiz, String questionId, dynamic answer) {
    try {
      final question = quiz.questions.firstWhere((q) => q.id == questionId);

      if (question.type == 'with_free_answer') {
        final correct = question.correctAnswer?.trim().toLowerCase() ?? '';
        return answer.toString().trim().toLowerCase() == correct;
      }

      if (question.type == 'multi_choice') {
        final correctIds = question.options
            .where((o) => o.isCorrect)
            .map((o) => o.id)
            .toSet();
        if (answer is List) {
          final answerSet = Set<String>.from(answer.map((e) => e.toString()));
          return correctIds.length == answerSet.length &&
              correctIds.containsAll(answerSet);
        }
        return false;
      }

      // single_choice
      final correctOption = question.options.firstWhere((o) => o.isCorrect,
          orElse: () => question.options.first);
      return answer.toString() == correctOption.id;
    } catch (_) {
      return false;
    }
  }

  String? _getExplanation(QuizModel quiz, String questionId) {
    try {
      final question = quiz.questions.firstWhere((q) => q.id == questionId);
      return question.explanation;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<QuizSessionModel> startSession(String quizId) async {
    final session = QuizSessionModel(
      id: 'session-${_nextId++}',
      quizId: quizId,
      userId: 'mock-user-1',
      status: 'in_progress',
      answers: [],
      startedAt: DateTime.now().toIso8601String(),
    );
    await _saveSession(session);
    return session;
  }

  @override
  Future<QuizSessionModel> getSession(String sessionId) async {
    final session = _readSession(sessionId);
    if (session == null) throw Exception('Session not found: $sessionId');
    return session;
  }

  @override
  Future<Map<String, dynamic>> submitAnswer({
    required String sessionId,
    required String questionId,
    required dynamic answer,
  }) async {
    final session = _readSession(sessionId);
    if (session == null) throw Exception('Session not found');

    final quiz = _findQuiz(session.quizId);
    if (quiz == null) throw Exception('Quiz not found');

    final correct = _evaluateAnswer(quiz, questionId, answer);
    final explanation = correct ? null : _getExplanation(quiz, questionId);

    final updatedAnswers = [
      ...session.answers,
      AnswerRecordModel(
        questionId: questionId,
        answer: answer,
        correct: correct,
        explanation: explanation,
      ),
    ];

    final updated = QuizSessionModel(
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
    await _saveSession(updated);

    return {
      'correct': correct,
      'explanation': explanation,
    };
  }

  @override
  Future<QuizSessionModel> completeSession(String sessionId) async {
    final session = _readSession(sessionId);
    if (session == null) throw Exception('Session not found');

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
    await _saveSession(completed);
    return completed;
  }

  @override
  Future<List<QuizSessionModel>> getMySessions() async {
    final box = HiveStorage.sessionsBox;
    final sessions = <QuizSessionModel>[];
    for (final key in box.keys) {
      final raw = box.get(key.toString());
      if (raw == null) continue;
      try {
        sessions.add(QuizSessionModel.fromJson(
            jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {}
    }
    return sessions.where((s) => s.userId == 'mock-user-1').toList();
  }
}
