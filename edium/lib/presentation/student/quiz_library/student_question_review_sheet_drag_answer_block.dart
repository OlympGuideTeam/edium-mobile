part of 'student_question_review_sheet.dart';

class _DragAnswerBlock extends StatelessWidget {
  final List<String> studentOrder;
  final List<String> correctOrder;

  const _DragAnswerBlock({
    required this.studentOrder,
    required this.correctOrder,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  bool get _isFullyCorrect =>
      studentOrder.length == correctOrder.length &&
      List.generate(studentOrder.length, (i) => studentOrder[i] == correctOrder[i])
          .every((b) => b);

  @override
  Widget build(BuildContext context) {
    if (studentOrder.isEmpty) {
      return _emptyAnswer();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ваш порядок', style: AppTextStyles.fieldLabel),
        const SizedBox(height: 6),
        ...studentOrder.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isCorrectPos = i < correctOrder.length && correctOrder[i] == item;
          return Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isCorrectPos ? _greenBg : _redBg,
              borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              border: Border.all(color: isCorrectPos ? _green : _red),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isCorrectPos ? _green : _red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCorrectPos ? _green : _red,
                    ),
                  ),
                ),
                Icon(
                  isCorrectPos ? Icons.check : Icons.close,
                  size: 15,
                  color: isCorrectPos ? _green : _red,
                ),
              ],
            ),
          );
        }),
        if (!_isFullyCorrect) ...[
          const SizedBox(height: 12),
          Text('Правильный порядок', style: AppTextStyles.fieldLabel),
          const SizedBox(height: 6),
          ...correctOrder.asMap().entries.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _greenBg,
                  borderRadius: BorderRadius.circular(AppDimens.radiusSm),
                  border: Border.all(color: _green),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${e.key + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 14, color: _green),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  Widget _emptyAnswer() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.mono50,
          borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          border: Border.all(color: AppColors.mono150),
        ),
        child: const Text('— нет ответа —',
            style: TextStyle(fontSize: 14, color: AppColors.mono400)),
      );
}

