part of 'live_student_screen.dart';

class _LockedPhase extends StatelessWidget {
  final LiveStudentQuestionLocked state;
  const _LockedPhase({required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            Container(
              color: AppColors.liveDarkSurface,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Вопрос ${state.questionIndex}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                      const Spacer(),
                      _CorrectnessBadge(myResult: state.myResult),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.liveDarkCard,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 1.0,
                        heightFactor: 1.0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.question.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                    ),
                    if (state.question.imageId != null) ...[
                      const SizedBox(height: 16),
                      QuestionImageWidget(imageId: state.question.imageId!, dark: true),
                    ],
                    const SizedBox(height: 24),
                    _buildLockedContent(),
                    const SizedBox(height: 24),
                    if (state.stats is LiveChoiceStats || state.stats is LiveBinaryStats)
                      _GivenAnswerDistribution(stats: state.stats),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: _PulsingWaitBadge(text: 'Ожидайте следующий вопрос...'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedContent() {
    switch (state.question.type) {
      case QuestionType.singleChoice:
      case QuestionType.multiChoice:
        return _LockedChoiceDistribution(
          question: state.question,
          stats: state.stats is LiveChoiceStats
              ? state.stats as LiveChoiceStats
              : null,
          correctAnswer: state.correctAnswer,
          myAnswer: state.myAnswer,
        );
      case QuestionType.withGivenAnswer:
        return _WordCloudView(
          words: state.wordCloud ?? [],
          correctAnswers: state.correctAnswer.correctAnswers ?? [],
        );
      case QuestionType.drag:
        return _LockedDragResult(correctAnswer: state.correctAnswer);
      case QuestionType.connection:
        final rawPairs =
            state.myAnswer?['pairs'] as Map<String, dynamic>?;
        if (rawPairs != null && rawPairs.isNotEmpty) {
          return _LockedConnectionMyAnswer(
            question: state.question,
            myPairs: rawPairs.map((k, v) => MapEntry(k, v.toString())),
            correctPairs: state.correctAnswer.correctPairs ?? {},
          );
        }
        return _LockedConnectionResult(correctAnswer: state.correctAnswer);
      default:
        return const SizedBox.shrink();
    }
  }
}

