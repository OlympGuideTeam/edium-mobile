part of 'student_question_review_sheet.dart';

class StudentQuestionReviewMockPreview extends StatelessWidget {
  const StudentQuestionReviewMockPreview({super.key});


  static final _mockQuestions = [

    const QuizQuestionForStudent(
      id: 'q004-1',
      type: QuizQuestionType.drag,
      text: 'Расставьте этапы разработки в правильном порядке:',
      maxScore: 10,
      metadata: {
        'items': ['Тестирование', 'Дизайн', 'Требования', 'Разработка'],
        'correct_order': ['Требования', 'Дизайн', 'Разработка', 'Тестирование'],
      },
    ),

    const QuizQuestionForStudent(
      id: 'q004-2',
      type: QuizQuestionType.connection,
      text: 'Сопоставьте концепцию с её определением:',
      maxScore: 10,
      metadata: {
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

    const QuizQuestionForStudent(
      id: 'q001-1',
      type: QuizQuestionType.singleChoice,
      text: 'Какой тип является nullable в Dart?',
      maxScore: 10,
      options: [
        QuestionOptionForStudent(id: 'q001-1-a', text: 'int'),
        QuestionOptionForStudent(id: 'q001-1-b', text: 'int?'),
        QuestionOptionForStudent(id: 'q001-1-c', text: 'String'),
        QuestionOptionForStudent(id: 'q001-1-d', text: 'dynamic'),
      ],
      metadata: {'correct_option_ids': ['q001-1-b']},
    ),

    const QuizQuestionForStudent(
      id: 'q001-3',
      type: QuizQuestionType.withGivenAnswer,
      text: 'Напишите ключевое слово для асинхронной функции в Dart.',
      maxScore: 10,
      metadata: {
        'correct_answers': ['async', 'async*'],
      },
    ),

    const QuizQuestionForStudent(
      id: 'q001-4',
      type: QuizQuestionType.withFreeAnswer,
      text: 'Объясните разницу между final и const в Dart.',
      maxScore: 10,
    ),

    const QuizQuestionForStudent(
      id: 'q003-3',
      type: QuizQuestionType.withFreeAnswer,
      text: 'Опишите значение реформ Петра I для развития России.',
      maxScore: 10,
    ),
  ];

  static final _mockAnswers = [

    const AnswerSubmissionResult(
      questionId: 'q004-1',
      answerData: {
        'order': ['Дизайн', 'Требования', 'Тестирование', 'Разработка'],
      },
      finalScore: 0,
      finalSource: 'auto',
      correctData: {
        'correct_order': ['Требования', 'Дизайн', 'Разработка', 'Тестирование'],
      },
    ),

    const AnswerSubmissionResult(
      questionId: 'q004-2',
      answerData: {
        'pairs': {
          'Инкапсуляция': 'Переопределение методов',
          'Наследование': 'Расширение класса',
          'Полиморфизм': 'Скрытие данных',
        },
      },
      finalScore: 0,
      finalSource: 'auto',
      correctData: {
        'correct_pairs': {
          'Инкапсуляция': 'Скрытие данных',
          'Наследование': 'Расширение класса',
          'Полиморфизм': 'Переопределение методов',
        },
      },
    ),

    const AnswerSubmissionResult(
      questionId: 'q001-1',
      answerData: {'selected_option_id': 'q001-1-a'},
      finalScore: 0,
      finalSource: 'auto',
      correctData: {'correct_option_ids': ['q001-1-b']},
    ),

    const AnswerSubmissionResult(
      questionId: 'q001-3',
      answerData: {'text': 'async'},
      finalScore: 10,
      finalSource: 'auto',
      correctData: {'correct_answers': ['async', 'async*']},
    ),

    const AnswerSubmissionResult(
      questionId: 'q001-4',
      answerData: {
        'text':
            'final — значение присваивается один раз во время выполнения, const — компилируемая константа.',
      },
      finalScore: 8,
      finalSource: 'teacher',
      finalFeedback: 'Хорошо, но стоило привести пример с объектами.',
    ),

    const AnswerSubmissionResult(
      questionId: 'q003-3',
      answerData: {
        'text': 'Пётр I провёл военные, административные и культурные реформы.',
      },
      finalScore: 7,
      finalSource: 'teacher',
      finalFeedback: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        title: const Text('Мок: разбор вопросов'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.mono900,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimens.screenPaddingH),
        itemCount: _mockQuestions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final q = _mockQuestions[i];
          final a = _mockAnswers[i];
          return GestureDetector(
            onTap: () => showStudentQuestionReview(
              context,
              data: StudentQuestionReviewData(
                index: i + 1,
                total: _mockQuestions.length,
                question: q,
                answer: a,
              ),
            ),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                border: Border.all(color: AppColors.mono150),
              ),
              child: Row(
                children: [
                  Text(
                    '${i + 1}.',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono400,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      q.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.mono900),
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.mono300),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

