part of 'student_question_review_sheet.dart';

class _ConnectionAnswerBlock extends StatelessWidget {
  final Map<String, String> studentPairs;
  final Map<String, String> correctPairs;

  const _ConnectionAnswerBlock({
    required this.studentPairs,
    required this.correctPairs,
  });

  static const _green = Color(0xFF22C55E);
  static const _greenBg = Color(0xFFE8F5E9);
  static const _red = Color(0xFFEF4444);
  static const _redBg = Color(0xFFFEE2E2);

  @override
  Widget build(BuildContext context) {
    if (studentPairs.isEmpty) {
      return Container(
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

    final hasCorrect = correctPairs.isNotEmpty;
    final keys = hasCorrect
        ? correctPairs.keys.toList()
        : studentPairs.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: keys.map((left) {
        final studentRight = studentPairs[left];
        final correctRight = hasCorrect ? correctPairs[left] : null;
        final isCorrect = hasCorrect ? studentRight == correctRight : null;

        final Color accentColor;
        final Color bgColor;
        final Color borderColor;
        if (isCorrect == true) {
          accentColor = _green;
          bgColor = _greenBg;
          borderColor = _green;
        } else if (isCorrect == false) {
          accentColor = _red;
          bgColor = _redBg;
          borderColor = _red;
        } else {
          accentColor = AppColors.mono600;
          bgColor = AppColors.mono50;
          borderColor = AppColors.mono150;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 7),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                left,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.arrow_forward, size: 13, color: accentColor),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      studentRight ?? '—',
                      style: TextStyle(fontSize: 13, color: accentColor),
                    ),
                  ),
                  if (isCorrect != null)
                    Icon(
                      isCorrect! ? Icons.check_circle : Icons.cancel,
                      size: 15,
                      color: accentColor,
                    ),
                ],
              ),
              if (isCorrect == false && correctRight != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.check, size: 13, color: _green),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        correctRight,
                        style: const TextStyle(fontSize: 13, color: _green),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

