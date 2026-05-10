part of 'teacher_grade_attempt_screen.dart';

class _GradeBody extends StatelessWidget {
  final AttemptReview review;
  final bool isSaving;
  final String attemptId;
  final LocalGrades localGrades;

  const _GradeBody({
    required this.review,
    required this.isSaving,
    required this.attemptId,
    required this.localGrades,
  });

  bool _isReadyToSubmit(LocalGrades localGrades) => review.answers
      .where((a) => a.questionType == QuizQuestionType.withFreeAnswer)
      .every((a) => localGrades.containsKey(a.submissionId));

  @override
  Widget build(BuildContext context) {
    final answers = review.answers;
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
                AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 16),
            children: [
              const SizedBox(height: 8),
              const Text('Проверка работы', style: AppTextStyles.screenTitle),
              const SizedBox(height: 6),
              Text(
                review.score != null
                    ? 'Текущий балл: ${review.score!.toStringAsFixed(0)}'
                    : 'Балл не выставлен',
                style: AppTextStyles.screenSubtitle,
              ),
              const SizedBox(height: 20),
              ...answers.asMap().entries.map((e) {
                final answer = e.value;
                if (answer.questionType == QuizQuestionType.withFreeAnswer) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FreeAnswerInlineCard(
                      index: e.key + 1,
                      answer: answer,
                      initialScore: localGrades[answer.submissionId]?.score,
                      initialFeedback: localGrades[answer.submissionId]?.feedback,
                      onGradeChanged: (score, feedback) {
                        context.read<TeacherGradeBloc>().add(
                              UpdateLocalGradeEvent(
                                submissionId: answer.submissionId,
                                score: score,
                                feedback: feedback,
                              ),
                            );
                      },
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ReadonlyAnswerCard(index: e.key + 1, answer: answer),
                );
              }),
            ],
          ),
        ),
        _SubmitButton(
          isSaving: isSaving,
          isReady: _isReadyToSubmit(localGrades),
          onTap: () {
            context
                .read<TeacherGradeBloc>()
                .add(CompleteGradingEvent(attemptId));
          },
        ),
      ],
    );
  }

}

