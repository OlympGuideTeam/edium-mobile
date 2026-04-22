import 'package:edium/data/datasources/quiz/quiz_datasource.dart';
import 'package:edium/data/models/question_model.dart';
import 'package:edium/data/models/quiz_model.dart';

class QuizDatasourceMock implements IQuizDatasource {
  final List<QuizModel> _quizzes = _buildMockQuizzes();
  int _nextId = 10;

  static List<QuizModel> _buildMockQuizzes() {
    return [
      QuizModel(
        id: '1',
        title: 'Алгебра: Квадратные уравнения',
        subject: 'Математика',
        authorId: 'mock-user-1',
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
              AnswerOptionModel(id: 'a', text: 'Один корень', isCorrect: false),
              AnswerOptionModel(id: 'b', text: 'Два корня', isCorrect: true),
              AnswerOptionModel(id: 'c', text: 'Нет корней', isCorrect: false),
              AnswerOptionModel(id: 'd', text: 'Бесконечно много', isCorrect: false),
            ],
            explanation: 'Дискриминант D = 25 - 24 = 1 > 0, значит уравнение имеет два различных корня.',
            orderIndex: 0,
          ),
          QuestionModel(
            id: 'q2',
            text: 'Найдите корни уравнения x² - 4 = 0',
            type: 'multi_choice',
            options: [
              AnswerOptionModel(id: 'a', text: 'x = 2', isCorrect: true),
              AnswerOptionModel(id: 'b', text: 'x = -2', isCorrect: true),
              AnswerOptionModel(id: 'c', text: 'x = 4', isCorrect: false),
              AnswerOptionModel(id: 'd', text: 'x = 0', isCorrect: false),
            ],
            explanation: 'x² = 4, x = ±2',
            orderIndex: 1,
          ),
          QuestionModel(
            id: 'q3',
            text: 'Чему равна сумма корней уравнения x² - 7x + 12 = 0?',
            type: 'with_free_answer',
            options: [],
            explanation: 'По теореме Виета: сумма корней = -b/a = 7/1 = 7',
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
              AnswerOptionModel(id: 'a', text: '1855', isCorrect: false),
              AnswerOptionModel(id: 'b', text: '1861', isCorrect: true),
              AnswerOptionModel(id: 'c', text: '1917', isCorrect: false),
              AnswerOptionModel(id: 'd', text: '1881', isCorrect: false),
            ],
            explanation: 'Крестьянская реформа 1861 года — манифест Александра II об отмене крепостного права.',
            orderIndex: 0,
          ),
          QuestionModel(
            id: 'q5',
            text: 'Кто из перечисленных правил Россией в XIX веке?',
            type: 'multi_choice',
            options: [
              AnswerOptionModel(id: 'a', text: 'Александр I', isCorrect: true),
              AnswerOptionModel(id: 'b', text: 'Николай I', isCorrect: true),
              AnswerOptionModel(id: 'c', text: 'Пётр I', isCorrect: false),
              AnswerOptionModel(id: 'd', text: 'Александр II', isCorrect: true),
            ],
            explanation: 'В XIX веке правили: Павел I (до 1801), Александр I, Николай I, Александр II, Александр III.',
            orderIndex: 1,
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
        authorId: 'mock-user-1',
        authorName: 'Алексей Иванов',
        status: 'draft',
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
              AnswerOptionModel(id: 'a', text: 'O(1)', isCorrect: false),
              AnswerOptionModel(id: 'b', text: 'O(n)', isCorrect: false),
              AnswerOptionModel(id: 'c', text: 'O(log n)', isCorrect: true),
              AnswerOptionModel(id: 'd', text: 'O(n²)', isCorrect: false),
            ],
            explanation: 'Бинарный поиск делит массив пополам на каждом шаге, что даёт O(log n).',
            orderIndex: 0,
          ),
        ],
        likesCount: 3,
        isLiked: false,
        createdAt: '2026-03-01T09:00:00Z',
      ),
    ];
  }

  @override
  Future<List<QuizModel>> getQuizzes({
    String scope = 'global',
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    var result = List<QuizModel>.from(_quizzes);
    if (scope == 'mine') {
      result = result.where((q) => q.authorId == 'mock-user-1').toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      result = result
          .where((quiz) => quiz.title.toLowerCase().contains(q))
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
    await Future.delayed(const Duration(milliseconds: 600));
    final id = '${++_nextId}';
    final timeLimitMinutes =
        totalTimeLimitSec != null ? (totalTimeLimitSec / 60).round() : null;
    final newQuiz = QuizModel(
      id: id,
      title: title,
      subject: '',
      authorId: 'mock-user-1',
      authorName: 'Алексей Иванов',
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
    _quizzes.add(newQuiz);
    return id;
  }

  @override
  Future<QuizModel> getQuizById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _quizzes.firstWhere((q) => q.id == id);
  }

  @override
  Future<Map<String, dynamic>> likeQuiz(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _quizzes.indexWhere((q) => q.id == id);
    if (idx == -1) return {'liked': false, 'likes_count': 0};
    final quiz = _quizzes[idx];
    final liked = !quiz.isLiked;
    _quizzes[idx] = QuizModel(
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
    return {'liked': liked, 'likes_count': _quizzes[idx].likesCount};
  }

  @override
  Future<void> publishQuiz(String id, {required bool isPublic}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _quizzes.indexWhere((q) => q.id == id);
    if (idx == -1) return;
    final quiz = _quizzes[idx];
    _quizzes[idx] = QuizModel(
      id: quiz.id,
      title: quiz.title,
      subject: quiz.subject,
      authorId: quiz.authorId,
      authorName: quiz.authorName,
      status: isPublic ? 'active' : 'active',
      settings: quiz.settings,
      questions: quiz.questions,
      likesCount: quiz.likesCount,
      isLiked: quiz.isLiked,
      createdAt: quiz.createdAt,
      summaryQuestionCount: quiz.summaryQuestionCount,
    );
  }

  @override
  Future<String> copyQuiz(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final original = _quizzes.firstWhere((q) => q.id == id);
    final newId = '${++_nextId}';
    _quizzes.add(QuizModel(
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
    ));
    return newId;
  }

  @override
  Future<Map<String, dynamic>> getQuizResults(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'quiz_id': id,
      'total_attempts': 23,
      'average_score': 72.5,
      'completion_rate': 0.87,
      'student_results': [
        {'name': 'Мария Петрова', 'score': 3, 'total': 3, 'completed_at': '2026-03-10T14:22:00Z'},
        {'name': 'Дмитрий Смирнов', 'score': 2, 'total': 3, 'completed_at': '2026-03-10T15:05:00Z'},
        {'name': 'Анна Козлова', 'score': 3, 'total': 3, 'completed_at': '2026-03-11T09:14:00Z'},
        {'name': 'Иван Новиков', 'score': 1, 'total': 3, 'completed_at': '2026-03-11T11:30:00Z'},
      ],
    };
  }

  @override
  Future<void> deleteQuiz(String id) async {
    _quizzes.removeWhere((q) => q.id == id);
  }

  @override
  Future<void> updateQuiz(
    String id, {
    String? title,
    String? description,
    Map<String, dynamic>? defaultSettings,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _quizzes.indexWhere((q) => q.id == id);
    if (idx == -1) return;
    final q = _quizzes[idx];
    final settings = defaultSettings != null
        ? QuizSettingsModel.fromRiddlerDefaultSettings(defaultSettings)
        : q.settings;
    _quizzes[idx] = QuizModel(
      id: q.id,
      title: title ?? q.title,
      description: description,
      subject: q.subject,
      authorId: q.authorId,
      authorName: q.authorName,
      status: q.status,
      settings: settings,
      questions: q.questions,
      likesCount: q.likesCount,
      isLiked: q.isLiked,
      createdAt: q.createdAt,
      summaryQuestionCount: q.summaryQuestionCount,
    );
  }

  @override
  Future<String> addQuestion(String quizId, Map<String, dynamic> questionData) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final idx = _quizzes.indexWhere((q) => q.id == quizId);
    if (idx == -1) throw Exception('Quiz not found');
    final q = _quizzes[idx];
    final newId = 'q_edit_${q.questions.length + 1}_${DateTime.now().millisecondsSinceEpoch}';
    final normalized = QuestionModel.normalizeTeacherQuestionPayload(
      Map<String, dynamic>.from(questionData),
    );
    final newQuestion = QuestionModel.fromJson({
      ...normalized,
      'id': newId,
      'order_index': q.questions.length,
    });
    _quizzes[idx] = QuizModel(
      id: q.id,
      title: q.title,
      description: q.description,
      subject: q.subject,
      authorId: q.authorId,
      authorName: q.authorName,
      status: q.status,
      settings: q.settings,
      questions: [...q.questions, newQuestion],
      likesCount: q.likesCount,
      isLiked: q.isLiked,
      createdAt: q.createdAt,
    );
    return newId;
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
  Future<void> removeQuestion(String quizId, String questionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _quizzes.indexWhere((q) => q.id == quizId);
    if (idx == -1) return;
    final q = _quizzes[idx];
    _quizzes[idx] = QuizModel(
      id: q.id,
      title: q.title,
      description: q.description,
      subject: q.subject,
      authorId: q.authorId,
      authorName: q.authorName,
      status: q.status,
      settings: q.settings,
      questions: q.questions.where((qm) => qm.id != questionId).toList(),
      likesCount: q.likesCount,
      isLiked: q.isLiked,
      createdAt: q.createdAt,
    );
  }

  @override
  Future<void> generateQuizQuestions(String quizId, String sourceText) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
