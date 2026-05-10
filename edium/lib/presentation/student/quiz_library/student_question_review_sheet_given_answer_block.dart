part of 'student_question_review_sheet.dart';

class _GivenAnswerBlock extends StatelessWidget {
  final String studentText;
  final List<String> correctAnswers;
  final bool isCorrect;

  const _GivenAnswerBlock({
    required this.studentText,
    required this.correctAnswers,
    required this.isCorrect,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    final hasAnswer = studentText.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ваш ответ', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: !hasAnswer
                ? AppColors.mono50
                : isCorrect
                    ? _greenBg
                    : _redBg,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(
              color: !hasAnswer
                  ? AppColors.mono150
                  : isCorrect
                      ? _green
                      : _red,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasAnswer ? studentText : '— нет ответа —',
                  style: TextStyle(
                    fontSize: 14,
                    color: !hasAnswer
                        ? AppColors.mono400
                        : isCorrect
                            ? _green
                            : _red,
                  ),
                ),
              ),
              if (hasAnswer)
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isCorrect ? _green : _red,
                ),
            ],
          ),
        ),
        if (correctAnswers.isNotEmpty && !isCorrect) ...[
          const SizedBox(height: 8),
          Text('Верный ответ', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _greenBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(color: _green),
            ),
            child: Text(
              correctAnswers.first,
              style: const TextStyle(fontSize: 14, color: _green),
            ),
          ),
        ],
      ],
    );
  }
}

