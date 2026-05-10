part of 'test_session_results_screen.dart';

class _StudentResultScreen extends StatefulWidget {
  final String attemptId;
  final String quizTitle;

  const _StudentResultScreen({
    required this.attemptId,
    required this.quizTitle,
  });

  @override
  State<_StudentResultScreen> createState() => _StudentResultScreenState();
}

class _StudentResultScreenState extends State<_StudentResultScreen> {
  late Future<AttemptReview> _future;

  @override
  void initState() {
    super.initState();
    _future = getIt<GetAttemptReviewUsecase>()(widget.attemptId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<AttemptReview>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.mono700, strokeWidth: 2),
              );
            }
            if (snap.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    snap.error.toString(),
                    style: AppTextStyles.screenSubtitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            final review = snap.data!;
            return _buildResultFromReview(context, review);
          },
        ),
      ),
    );
  }

  Widget _buildResultFromReview(BuildContext context, AttemptReview review) {

    const defaultMaxScore = 10;

    final questions = review.answers
        .map((a) => QuizQuestionForStudent(
              id: a.questionId,
              type: a.questionType,
              text: a.questionText,
              maxScore: defaultMaxScore,
            ))
        .toList();

    final answers = review.answers
        .map((a) => AnswerSubmissionResult(
              questionId: a.questionId,
              answerData: a.answerData,
              finalScore: a.finalScore,
              finalFeedback: a.finalFeedback,
            ))
        .toList();

    final result = AttemptResult(
      attemptId: review.attemptId,
      status: review.status,
      score: review.score,
      startedAt: review.startedAt,
      finishedAt: review.finishedAt,
      answers: answers,
    );

    final maxPossibleScore = questions.length * defaultMaxScore;

    return QuizResultScreen(
      result: result,
      maxPossibleScore: maxPossibleScore,
      quizTitle: widget.quizTitle,
      questions: questions,
      showBottomCta: false,
    );
  }
}

