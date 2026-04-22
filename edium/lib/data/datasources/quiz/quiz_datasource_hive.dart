import 'dart:convert';

import 'package:edium/core/storage/hive_storage.dart';
import 'package:edium/core/storage/profile_storage.dart';
import 'package:edium/data/datasources/quiz/quiz_datasource.dart';
import 'package:edium/data/models/question_model.dart';
import 'package:edium/data/models/quiz_model.dart';
import 'package:edium/data/models/quiz_session_model.dart';

class QuizDatasourceHive implements IQuizDatasource {
  final ProfileStorage _profileStorage;

  QuizDatasourceHive(this._profileStorage);

  Future<void> _ensureSeeded() async {
    final box = HiveStorage.quizzesBox;
    if (box.containsKey('__seeded')) return;
    for (final q in _buildSeedQuizzes()) {
      await box.put(q.id, jsonEncode(q.toJson()));
    }
    await box.put('__seeded', 'true');
  }

  List<QuizModel> _readAll() {
    final box = HiveStorage.quizzesBox;
    final result = <QuizModel>[];
    for (final key in box.keys) {
      if (key.toString().startsWith('_')) continue;
      final raw = box.get(key.toString());
      if (raw == null) continue;
      try {
        result.add(QuizModel.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } catch (_) {}
    }
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return result;
  }

  Future<void> _autoExpireDeadlines() async {
    final box = HiveStorage.quizzesBox;
    final now = DateTime.now();
    for (final quiz in _readAll()) {
      if (quiz.status != 'active') continue;
      final deadline = quiz.settings.deadline;
      if (deadline == null) continue;
      final dt = DateTime.tryParse(deadline);
      if (dt != null && dt.isBefore(now)) {
        final updated = QuizModel(
          id: quiz.id,
          title: quiz.title,
          subject: quiz.subject,
          authorId: quiz.authorId,
          authorName: quiz.authorName,
          status: 'completed',
          settings: quiz.settings,
          questions: quiz.questions,
          likesCount: quiz.likesCount,
          isLiked: quiz.isLiked,
          createdAt: quiz.createdAt,
          summaryQuestionCount: quiz.summaryQuestionCount,
        );
        await box.put(quiz.id, jsonEncode(updated.toJson()));
      }
    }
  }

  String _nextId() {
    final box = HiveStorage.quizzesBox;
    final keys = box.keys
        .where((k) => !k.toString().startsWith('_'))
        .map((k) => int.tryParse(k.toString()) ?? 0)
        .toList();
    if (keys.isEmpty) return '10';
    return '${keys.reduce((a, b) => a > b ? a : b) + 1}';
  }

  Map<String, dynamic> _buildRealResults(String quizId) {
    final sessionsBox = HiveStorage.sessionsBox;
    final sessions = <QuizSessionModel>[];
    for (final key in sessionsBox.keys) {
      final raw = sessionsBox.get(key.toString());
      if (raw == null) continue;
      try {
        final s =
            QuizSessionModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        if (s.quizId == quizId && s.status == 'completed') {
          sessions.add(s);
        }
      } catch (_) {}
    }

    if (sessions.isEmpty) {
      return {
        'quiz_id': quizId,
        'total_attempts': 0,
        'average_score': 0.0,
        'completion_rate': 0.0,
        'student_results': <Map<String, dynamic>>[],
      };
    }

    final totalAttempts = sessions.length;
    final scores = sessions.map((s) {
      final total = s.totalQuestions ?? s.answers.length;
      return total > 0 ? (s.score ?? 0) / total * 100 : 0.0;
    }).toList();
    final avgScore =
        scores.fold<double>(0, (a, b) => a + b) / scores.length;

    final studentResults = sessions.map((s) {
      return {
        'name': _profileStorage.getName() ?? 'Студент',
        'score': s.score ?? 0,
        'total': s.totalQuestions ?? s.answers.length,
        'completed_at': s.completedAt ?? s.startedAt,
      };
    }).toList();

    return {
      'quiz_id': quizId,
      'total_attempts': totalAttempts,
      'average_score': double.parse(avgScore.toStringAsFixed(1)),
      'completion_rate': 1.0,
      'student_results': studentResults,
    };
  }

  @override
  Future<List<QuizModel>> getQuizzes({
    String scope = 'global',
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    await _ensureSeeded();
    await _autoExpireDeadlines();
    var result = _readAll();
    if (scope == 'mine') {
      result = result.where((q) => q.authorId == 'mock-user-1').toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result
          .where((quiz) =>
              quiz.title.toLowerCase().contains(q) ||
              quiz.subject.toLowerCase().contains(q))
          .toList();
    }
    return result;
  }

  @override
  Future<String> createTestSession({
    required String quizTemplateId,
    required String moduleId,
    int? totalTimeLimitSec,
    bool shuffleQuestions = false,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'session-test-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String> createLiveSession({
    required String quizTemplateId,
    required String moduleId,
    int? questionTimeLimitSec,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'session-live-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<String> createQuiz({
    required String title,
    String? description,
    String? mode,
    int? totalTimeLimitSec,
    int? questionTimeLimitSec,
    bool shuffleQuestions = false,
    DateTime? startedAt,
    DateTime? finishedAt,
    required List<Map<String, dynamic>> questions,
    String? courseId,
  }) async {
    await _ensureSeeded();
    final id = _nextId();
    final authorName = _profileStorage.getName() ?? 'Преподаватель';
    final timeLimitMinutes = totalTimeLimitSec != null
        ? (totalTimeLimitSec / 60).round()
        : null;
    final newQuiz = QuizModel(
      id: id,
      title: title,
      subject: '',
      authorId: 'mock-user-1',
      authorName: authorName,
      status: 'draft',
      settings: QuizSettingsModel(
        timeLimitMinutes: timeLimitMinutes,
        shuffleQuestions: shuffleQuestions,
        showExplanations: false,
      ),
      questions: questions
          .asMap()
          .entries
          .map((e) => QuestionModel.fromJson(
              {...e.value, 'id': 'nq${e.key}', 'order_index': e.key}))
          .toList(),
      likesCount: 0,
      isLiked: false,
      createdAt: DateTime.now().toIso8601String(),
    );
    await HiveStorage.quizzesBox.put(id, jsonEncode(newQuiz.toJson()));
    return id;
  }

  @override
  Future<QuizModel> getQuizById(String id) async {
    await _ensureSeeded();
    await _autoExpireDeadlines();
    return _readAll().firstWhere((q) => q.id == id);
  }

  @override
  Future<Map<String, dynamic>> likeQuiz(String id) async {
    await _ensureSeeded();
    final all = _readAll();
    final idx = all.indexWhere((q) => q.id == id);
    if (idx == -1) return {'liked': false, 'likes_count': 0};
    final quiz = all[idx];
    final liked = !quiz.isLiked;
    final updated = QuizModel(
      id: quiz.id,
      title: quiz.title,
      subject: quiz.subject,
      authorId: quiz.authorId,
      authorName: quiz.authorName,
      status: quiz.status,
      settings: quiz.settings,
      questions: quiz.questions,
      likesCount: liked ? quiz.likesCount + 1 : quiz.likesCount - 1,
      isLiked: liked,
      createdAt: quiz.createdAt,
      summaryQuestionCount: quiz.summaryQuestionCount,
    );
    await HiveStorage.quizzesBox.put(id, jsonEncode(updated.toJson()));
    return {'liked': liked, 'likes_count': updated.likesCount};
  }

  @override
  Future<Map<String, dynamic>> getQuizResults(String id) async {
    await _ensureSeeded();
    return _buildRealResults(id);
  }

  @override
  Future<void> publishQuiz(String id, {required bool isPublic}) async {
    await _ensureSeeded();
    final all = _readAll();
    final idx = all.indexWhere((q) => q.id == id);
    if (idx == -1) return;
    final quiz = all[idx];
    final updated = QuizModel(
      id: quiz.id,
      title: quiz.title,
      subject: quiz.subject,
      authorId: quiz.authorId,
      authorName: quiz.authorName,
      status: 'active',
      settings: quiz.settings,
      questions: quiz.questions,
      likesCount: quiz.likesCount,
      isLiked: quiz.isLiked,
      createdAt: quiz.createdAt,
      summaryQuestionCount: quiz.summaryQuestionCount,
    );
    await HiveStorage.quizzesBox.put(id, jsonEncode(updated.toJson()));
  }

  @override
  Future<String> copyQuiz(String id) async {
    await _ensureSeeded();
    final original = _readAll().firstWhere((q) => q.id == id);
    final newId = _nextId();
    final copy = QuizModel(
      id: newId,
      title: '${original.title} (копия)',
      subject: original.subject,
      authorId: original.authorId,
      authorName: original.authorName,
      status: 'draft',
      settings: original.settings,
      questions: original.questions,
      likesCount: 0,
      isLiked: false,
      createdAt: DateTime.now().toIso8601String(),
    );
    await HiveStorage.quizzesBox.put(newId, jsonEncode(copy.toJson()));
    return newId;
  }

  @override
  Future<void> deleteQuiz(String id) async {
    await HiveStorage.quizzesBox.delete(id);
  }

  @override
  Future<void> updateQuiz(
    String id, {
    String? title,
    String? description,
    Map<String, dynamic>? defaultSettings,
  }) async {
    final raw = HiveStorage.quizzesBox.get(id);
    if (raw == null) return;
    final json = jsonDecode(raw.toString()) as Map<String, dynamic>;
    if (title != null) json['title'] = title;
    json['description'] = description;
    if (defaultSettings != null) {
      json['default_settings'] = defaultSettings;
      final model = QuizModel.fromJson(json);
      await HiveStorage.quizzesBox.put(id, jsonEncode(model.toJson()));
    } else {
      await HiveStorage.quizzesBox.put(id, jsonEncode(json));
    }
  }

  @override
  Future<String> addQuestion(String quizId, Map<String, dynamic> questionData) async {
    final raw = HiveStorage.quizzesBox.get(quizId);
    if (raw == null) throw Exception('Quiz not found');
    final json = jsonDecode(raw.toString()) as Map<String, dynamic>;
    final questions = List<Map<String, dynamic>>.from(
      (json['questions'] as List<dynamic>? ?? []).map((e) => e as Map<String, dynamic>),
    );
    final newId = 'q_hive_${questions.length + 1}_${DateTime.now().millisecondsSinceEpoch}';
    final normalized = QuestionModel.normalizeTeacherQuestionPayload(
      Map<String, dynamic>.from(questionData),
    );
    questions.add({...normalized, 'id': newId, 'order_index': questions.length});
    json['questions'] = questions;
    await HiveStorage.quizzesBox.put(quizId, jsonEncode(json));
    return newId;
  }

  @override
  Future<void> removeQuestion(String quizId, String questionId) async {
    final raw = HiveStorage.quizzesBox.get(quizId);
    if (raw == null) return;
    final json = jsonDecode(raw.toString()) as Map<String, dynamic>;
    final questions = List<Map<String, dynamic>>.from(
      (json['questions'] as List<dynamic>? ?? []).map((e) => e as Map<String, dynamic>),
    );
    questions.removeWhere((q) => q['id'] == questionId);
    json['questions'] = questions;
    await HiveStorage.quizzesBox.put(quizId, jsonEncode(json));
  }

  @override
  Future<String> createTestSessionInline({
    required String title,
    String? description,
    required String courseId,
    required String moduleId,
    required List<Map<String, dynamic>> questions,
    int? totalTimeLimitSec,
    bool shuffleQuestions = false,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) async {
    await createQuiz(
      title: title,
      description: description,
      mode: 'test',
      totalTimeLimitSec: totalTimeLimitSec,
      shuffleQuestions: shuffleQuestions,
      startedAt: startedAt,
      finishedAt: finishedAt,
      questions: questions,
    );
    return 'session-inline-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> generateQuizQuestions(String quizId, String sourceText) async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  static List<QuizModel> _buildSeedQuizzes() => [
        QuizModel(
          id: '1',
          title: 'Алгебра: Квадратные уравнения',
          subject: 'Математика',
          authorId: 'mock-user-2',
          authorName: 'Алексей Иванов',
          status: 'active',
          settings: const QuizSettingsModel(
            timeLimitMinutes: 20,
            shuffleQuestions: true,
            showExplanations: true,
          ),
          questions: [
            QuestionModel(
              id: 'q1',
              text: 'Сколько корней имеет уравнение x² - 5x + 6 = 0?',
              type: 'single_choice',
              options: [
                const AnswerOptionModel(
                    id: 'a', text: 'Один корень', isCorrect: false),
                const AnswerOptionModel(
                    id: 'b', text: 'Два корня', isCorrect: true),
                const AnswerOptionModel(
                    id: 'c', text: 'Нет корней', isCorrect: false),
                const AnswerOptionModel(
                    id: 'd', text: 'Бесконечно много', isCorrect: false),
              ],
              explanation:
                  'Дискриминант D = 25 - 24 = 1 > 0, значит два различных корня.',
              orderIndex: 0,
            ),
            QuestionModel(
              id: 'q2',
              text: 'Найдите корни уравнения x² - 4 = 0',
              type: 'multiple_choice',
              options: [
                const AnswerOptionModel(
                    id: 'a', text: 'x = 2', isCorrect: true),
                const AnswerOptionModel(
                    id: 'b', text: 'x = -2', isCorrect: true),
                const AnswerOptionModel(
                    id: 'c', text: 'x = 4', isCorrect: false),
                const AnswerOptionModel(
                    id: 'd', text: 'x = 0', isCorrect: false),
              ],
              explanation: 'x² = 4, x = ±2',
              orderIndex: 1,
            ),
            QuestionModel(
              id: 'q3',
              text: 'Чему равна сумма корней уравнения x² - 7x + 12 = 0?',
              type: 'with_given_answer',
              options: [],
              explanation: 'По теореме Виета: сумма корней = 7',
              correctAnswer: '7',
              orderIndex: 2,
            ),
          ],
          likesCount: 14,
          isLiked: false,
          createdAt: '2026-02-01T10:00:00Z',
        ),
        QuizModel(
          id: '2',
          title: 'История России: XIX век',
          subject: 'История',
          authorId: 'mock-user-2',
          authorName: 'Мария Петрова',
          status: 'active',
          settings: const QuizSettingsModel(
            timeLimitMinutes: 15,
            shuffleQuestions: false,
            showExplanations: true,
          ),
          questions: [
            QuestionModel(
              id: 'q4',
              text: 'В каком году было отменено крепостное право в России?',
              type: 'single_choice',
              options: [
                const AnswerOptionModel(
                    id: 'a', text: '1855', isCorrect: false),
                const AnswerOptionModel(
                    id: 'b', text: '1861', isCorrect: true),
                const AnswerOptionModel(
                    id: 'c', text: '1917', isCorrect: false),
                const AnswerOptionModel(
                    id: 'd', text: '1881', isCorrect: false),
              ],
              explanation:
                  'Крестьянская реформа 1861 года — манифест Александра II.',
              orderIndex: 0,
            ),
          ],
          likesCount: 7,
          isLiked: true,
          createdAt: '2026-02-10T12:00:00Z',
        ),
        QuizModel(
          id: '3',
          title: 'Алгоритмы и структуры данных',
          subject: 'Информатика',
          authorId: 'mock-user-3',
          authorName: 'Дмитрий Козлов',
          status: 'active',
          settings: const QuizSettingsModel(
            shuffleQuestions: false,
            showExplanations: true,
          ),
          questions: [
            QuestionModel(
              id: 'q6',
              text: 'Какова сложность алгоритма бинарного поиска?',
              type: 'single_choice',
              options: [
                const AnswerOptionModel(
                    id: 'a', text: 'O(1)', isCorrect: false),
                const AnswerOptionModel(
                    id: 'b', text: 'O(n)', isCorrect: false),
                const AnswerOptionModel(
                    id: 'c', text: 'O(log n)', isCorrect: true),
                const AnswerOptionModel(
                    id: 'd', text: 'O(n²)', isCorrect: false),
              ],
              explanation:
                  'Бинарный поиск делит массив пополам на каждом шаге — O(log n).',
              orderIndex: 0,
            ),
          ],
          likesCount: 3,
          isLiked: false,
          createdAt: '2026-03-01T09:00:00Z',
        ),
      ];
}
