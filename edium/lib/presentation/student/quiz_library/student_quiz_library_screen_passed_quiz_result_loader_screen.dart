part of 'student_quiz_library_screen.dart';

class _PassedQuizResultLoaderScreen extends StatefulWidget {
  final LibraryQuiz quiz;
  final String attemptId;

  const _PassedQuizResultLoaderScreen({
    required this.quiz,
    required this.attemptId,
  });

  @override
  State<_PassedQuizResultLoaderScreen> createState() =>
      _PassedQuizResultLoaderScreenState();
}

class _PassedQuizResultLoaderScreenState
    extends State<_PassedQuizResultLoaderScreen> {
  late final Future<(AttemptResult, List<QuizQuestionForStudent>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<(AttemptResult, List<QuizQuestionForStudent>)> _loadData() async {
    final result =
        await getIt<GetAttemptResultUsecase>().call(widget.attemptId);
    final review =
        await getIt<GetAttemptReviewUsecase>().call(widget.attemptId);

    final questions = review.answers.map((a) {
      final rawMaxScore = a.metadata?['max_score'];
      final maxScore = switch (rawMaxScore) {
        int v when v > 0 => v,
        num v when v > 0 => v.toInt(),
        _ => 10,
      };
      return QuizQuestionForStudent(
        id: a.questionId,
        type: a.questionType,
        text: a.questionText.isNotEmpty ? a.questionText : 'Вопрос',
        imageId: a.imageId,
        maxScore: maxScore,
        options: a.options
            ?.map((o) => QuestionOptionForStudent(id: o.id, text: o.text))
            .toList(),
        metadata: a.metadata,
      );
    }).toList();

    return (result, questions);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(AttemptResult, List<QuizQuestionForStudent>)>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.mono700,
                strokeWidth: 2,
              ),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.mono200,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Не удалось загрузить результаты',
                        style: AppTextStyles.screenSubtitle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Назад'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        final (result, questions) = snapshot.data!;
        final maxPossibleScore =
            questions.fold<int>(0, (sum, q) => sum + q.maxScore);

        return QuizResultScreen(
          result: result,
          maxPossibleScore: maxPossibleScore,
          quizTitle: widget.quiz.title,
          questions: questions,
          showBottomCta: false,
        );
      },
    );
  }
}

