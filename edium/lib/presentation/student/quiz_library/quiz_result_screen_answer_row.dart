part of 'quiz_result_screen.dart';

class _AnswerRow extends StatelessWidget {
  final int index;
  final _AnswerBreakdown breakdown;
  final int total;
  final QuizQuestionForStudent question;

  const _AnswerRow({
    required this.index,
    required this.breakdown,
    required this.total,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    final score = breakdown.answer.finalScore;
    final max = breakdown.maxScore;
    final scoreText = score == null
        ? '—'
        : '${score.toStringAsFixed(score % 1 == 0 ? 0 : 1)}/$max';

    return GestureDetector(
      onTap: () => showStudentQuestionReview(
        context,
        data: StudentQuestionReviewData(
          index: index,
          total: total,
          question: question,
          answer: breakdown.answer,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.mono150),
        ),
        child: Row(
          children: [
            _StatusDot(status: breakdown.status),
            const SizedBox(width: 12),
            SizedBox(
              width: 18,
              child: Text(
                '$index',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono400,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                breakdown.answer.finalFeedback != null &&
                        breakdown.answer.finalFeedback!.isNotEmpty
                    ? breakdown.answer.finalFeedback!
                    : 'Вопрос $index',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.mono900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              scoreText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _colorForStatus(breakdown.status),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.mono300),
          ],
        ),
      ),
    );
  }

  Color _colorForStatus(_AnswerStatus s) {
    switch (s) {
      case _AnswerStatus.correct:
        return _ResultBody._green;
      case _AnswerStatus.partial:
        return _ResultBody._amber;
      case _AnswerStatus.wrong:
        return _ResultBody._red;
      case _AnswerStatus.pending:
        return AppColors.mono400;
    }
  }
}

