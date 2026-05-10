part of 'teacher_grade_attempt_screen.dart';

class _ReadonlyAnswerCard extends StatelessWidget {
  final int index;
  final AnswerReview answer;

  const _ReadonlyAnswerCard({required this.index, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IndexBadge(index: index),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  answer.questionText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                    height: 1.3,
                  ),
                ),
              ),
              if (answer.finalScore != null)
                Text(
                  answer.finalScore!.toStringAsFixed(0),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.mono900,
                  ),
                )
              else
                const Text('—',
                    style: TextStyle(fontSize: 14, color: AppColors.mono300)),
            ],
          ),
          if (answer.imageId != null) ...[
            const SizedBox(height: 10),
            QuestionImageWidget(imageId: answer.imageId!),
          ],
          const SizedBox(height: 10),
          _answerPreview(answer),
        ],
      ),
    );
  }

  Widget _answerPreview(AnswerReview a) {
    switch (a.questionType) {
      case QuizQuestionType.singleChoice:
        final picked = a.answerData['selected_option_id'] as String?;
        return _optionsList(a.options ?? [], {if (picked != null) picked});
      case QuizQuestionType.multipleChoice:
        final picked = (a.answerData['selected_option_ids'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toSet();
        return _optionsList(a.options ?? [], picked);
      case QuizQuestionType.withGivenAnswer:
        final text = a.answerData['text']?.toString() ?? '';
        final correct = (a.metadata?['correct_answers'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ответ: $text',
                style: const TextStyle(fontSize: 13, color: AppColors.mono900)),
            if (correct != null)
              Text('Верные: ${correct.join(", ")}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.mono400)),
          ],
        );
      default:
        final raw = a.answerData.toString();
        return Text(raw,
            style: const TextStyle(fontSize: 13, color: AppColors.mono700));
    }
  }

  Widget _optionsList(List<TeacherAnswerOption> options, Set<String> picked) {
    if (options.isEmpty) return const SizedBox.shrink();
    return Column(
      children: options.map((o) {
        final ip = picked.contains(o.id);
        final ic = o.isCorrect;
        final bg = ic
            ? const Color(0xFFE8F5E9)
            : (ip ? const Color(0xFFFEE2E2) : Colors.white);
        final borderColor = ic
            ? const Color(0xFF22C55E)
            : (ip ? const Color(0xFFEF4444) : AppColors.mono150);
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Icon(
                ip
                    ? (ic ? Icons.check_circle : Icons.cancel)
                    : (ic ? Icons.check : Icons.radio_button_unchecked),
                size: 16,
                color: ic
                    ? const Color(0xFF22C55E)
                    : (ip ? const Color(0xFFEF4444) : AppColors.mono300),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(o.text,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.mono900)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

