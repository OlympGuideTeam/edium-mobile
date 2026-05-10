part of 'test_preview_screen.dart';

class _TestPreviewView extends StatelessWidget {
  final String sessionId;
  final String? courseId;
  const _TestPreviewView({required this.sessionId, this.courseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: _BackRow(onBack: () => context.pop()),
          ),
          Expanded(
            child: BlocConsumer<TestPreviewBloc, TestPreviewState>(

                listener: (context, state) {
                  if (state is TestPreviewLoaded &&
                      state.status == TestPreviewStatus.published &&
                      state.review != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!context.mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _buildResultScreen(
                            state.review!,
                            state.meta.title,
                          ),
                        ),
                      );
                    });
                  }
                },
                builder: (context, state) {
                  if (state is TestPreviewLoading ||
                      state is TestPreviewInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mono700,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (state is TestPreviewError) {
                    return _ErrorBody(message: state.message);
                  }
                  if (state is TestPreviewLoaded) {

                    if (state.status == TestPreviewStatus.published) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.mono700,
                          strokeWidth: 2,
                        ),
                      );
                    }
                    return _LoadedBody(
                      state: state,
                      sessionId: sessionId,
                      courseId: courseId,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildResultScreen(AttemptReview review, String quizTitle) {
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

    return QuizResultScreen(
      result: result,
      maxPossibleScore: questions.length * defaultMaxScore,
      quizTitle: quizTitle,
      questions: questions,
      showBottomCta: false,
    );
  }
}

