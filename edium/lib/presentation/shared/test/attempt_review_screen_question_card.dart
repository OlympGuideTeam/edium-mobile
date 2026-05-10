part of 'attempt_review_screen.dart';

class _QuestionCard extends StatelessWidget {
  final int index;
  final AnswerReview answer;
  final bool dark;
  const _QuestionCard({required this.index, required this.answer, this.dark = false});

  @override
  Widget build(BuildContext context) {
    final cardColor = dark
        ? Colors.white.withValues(alpha: 0.07)
        : AppColors.mono25;
    final borderColor = dark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.mono150;
    final numBg = dark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.mono100;
    final numTextColor = dark ? Colors.white70 : AppColors.mono600;
    final titleColor = dark ? Colors.white : AppColors.mono900;
    final scoreColor = dark ? Colors.white : AppColors.mono900;
    final dashColor = dark ? Colors.white38 : AppColors.mono300;
    final feedbackColor = dark ? Colors.white54 : AppColors.mono600;
    final sourceColor = dark ? Colors.white38 : AppColors.mono300;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: numBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text('$index',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: numTextColor,
                      )),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  answer.questionText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                    height: 1.3,
                  ),
                ),
              ),
              if (answer.finalScore != null)
                Text(
                  answer.finalScore!.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: scoreColor,
                  ),
                )
              else
                Text('—',
                    style: TextStyle(fontSize: 14, color: dashColor)),
            ],
          ),
          if (answer.imageId != null) ...[
            const SizedBox(height: 10),
            QuestionImageWidget(imageId: answer.imageId!),
          ],
          const SizedBox(height: 10),
          _answerBlock(answer),
          if (answer.finalFeedback != null &&
              answer.finalFeedback!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              answer.finalFeedback!,
              style: TextStyle(
                  fontSize: 12,
                  color: feedbackColor,
                  fontStyle: FontStyle.italic),
            ),
          ],
          if (answer.finalSource != null) ...[
            const SizedBox(height: 6),
            Text(
              _sourceLabel(answer.finalSource!),
              style: AppTextStyles.caption.copyWith(color: sourceColor),
            ),
          ],
        ],
      ),
    );
  }

  String _sourceLabel(String s) {
    switch (s) {
      case 'auto':
        return 'Проверено автоматически';
      case 'llm':
        return 'Проверено ИИ';
      case 'teacher':
        return 'Проверено учителем';
      default:
        return s;
    }
  }

  Widget _answerBlock(AnswerReview a) {
    switch (a.questionType) {
      case QuizQuestionType.singleChoice:
        return _singleChoiceBlock(a);
      case QuizQuestionType.multipleChoice:
        return _multiChoiceBlock(a);
      case QuizQuestionType.withGivenAnswer:
        return _givenAnswerBlock(a);
      case QuizQuestionType.withFreeAnswer:
        return _freeAnswerBlock(a);
      case QuizQuestionType.drag:
        return _dragBlock(a);
      case QuizQuestionType.connection:
        return _connectionBlock(a);
    }
  }

  Widget _singleChoiceBlock(AnswerReview a) {
    final picked = a.answerData['selected_option_id'] as String?;
    final options = a.options ?? const [];
    if (options.isEmpty && picked != null) {
      return Text('Выбран вариант: $picked',
          style: const TextStyle(fontSize: 13, color: AppColors.mono700));
    }
    return Column(
      children: options.map((o) {
        final isPicked = o.id == picked;
        final isCorrect = o.isCorrect;
        return _OptionLine(text: o.text, isPicked: isPicked, isCorrect: isCorrect);
      }).toList(),
    );
  }

  Widget _multiChoiceBlock(AnswerReview a) {
    final picked = (a.answerData['selected_option_ids'] as List<dynamic>? ??
            const [])
        .map((e) => e.toString())
        .toSet();
    final options = a.options ?? const [];
    if (options.isEmpty) {
      return Text('Выбрано: ${picked.join(", ")}',
          style: const TextStyle(fontSize: 13, color: AppColors.mono700));
    }
    return Column(
      children: options.map((o) {
        final isPicked = picked.contains(o.id);
        return _OptionLine(
            text: o.text, isPicked: isPicked, isCorrect: o.isCorrect);
      }).toList(),
    );
  }

  Widget _givenAnswerBlock(AnswerReview a) {
    final text = a.answerData['text']?.toString() ?? '';
    final correct = (a.metadata?['correct_answers'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ваш ответ: $text',
            style: const TextStyle(fontSize: 13, color: AppColors.mono900)),
        if (correct != null && correct.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text('Верные: ${correct.join(", ")}',
              style: AppTextStyles.caption.copyWith(color: AppColors.mono400)),
        ],
      ],
    );
  }

  Widget _freeAnswerBlock(AnswerReview a) {
    final text = a.answerData['text']?.toString() ?? '';
    return Text(text,
        style: const TextStyle(
            fontSize: 13, color: AppColors.mono900, height: 1.4));
  }

  Widget _dragBlock(AnswerReview a) {
    final studentOrder = (a.answerData['order'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .toList();
    final correctOrder = (a.metadata?['correct_order'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];

    if (studentOrder.isEmpty) return _emptyBlock();

    final isFullyCorrect = correctOrder.isNotEmpty &&
        studentOrder.length == correctOrder.length &&
        List.generate(
          studentOrder.length,
          (i) => studentOrder[i] == correctOrder[i],
        ).every((b) => b);

    if (isFullyCorrect || correctOrder.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: studentOrder.asMap().entries.map((e) {
          return _OrderItem(
            index: e.key + 1,
            text: e.value,
            isCorrect: true,
            showIcon: false,
          );
        }).toList(),
      );
    }

    final count = studentOrder.length > correctOrder.length
        ? studentOrder.length
        : correctOrder.length;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ВАШ ОТВЕТ', style: AppTextStyles.sectionTag),
              const SizedBox(height: 6),
              ...List.generate(count, (i) {
                final text =
                    i < studentOrder.length ? studentOrder[i] : '—';
                final isCorrect = i < correctOrder.length &&
                    i < studentOrder.length &&
                    studentOrder[i] == correctOrder[i];
                return _OrderItem(
                    index: i + 1,
                    text: text,
                    isCorrect: isCorrect,
                    showIcon: true);
              }),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('ПРАВИЛЬНО', style: AppTextStyles.sectionTag),
              const SizedBox(height: 6),
              ...List.generate(count, (i) {
                final text =
                    i < correctOrder.length ? correctOrder[i] : '—';
                return _OrderItem(
                    index: i + 1,
                    text: text,
                    isCorrect: true,
                    showIcon: false);
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _connectionBlock(AnswerReview a) {
    final studentPairs =
        (a.answerData['pairs'] as Map<String, dynamic>? ?? const {})
            .map((k, v) => MapEntry(k, v.toString()));
    final correctPairsRaw =
        a.metadata?['correct_pairs'] as Map<String, dynamic>?;
    final correctPairs = correctPairsRaw?.map((k, v) => MapEntry(k, v.toString()));
    final hasCorrect = correctPairs != null && correctPairs.isNotEmpty;

    if (studentPairs.isEmpty) return _emptyBlock();

    final keys = hasCorrect
        ? correctPairs.keys.toList()
        : studentPairs.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keys.map((left) {
        final studentRight = studentPairs[left];
        final correctRight = hasCorrect ? correctPairs[left] : null;
        final isCorrect = hasCorrect
            ? studentRight != null && studentRight == correctRight
            : null;

        return _ConnectionPairRow(
          left: left,
          studentRight: studentRight ?? '—',
          correctRight: isCorrect == false ? correctRight : null,
          isCorrect: isCorrect,
          dark: dark,
        );
      }).toList(),
    );
  }

  Widget _emptyBlock() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.mono50,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(color: AppColors.mono150),
        ),
        child: const Text('— нет ответа —',
            style: TextStyle(fontSize: 13, color: AppColors.mono400)),
      );
}

