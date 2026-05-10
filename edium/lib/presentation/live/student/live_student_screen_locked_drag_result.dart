part of 'live_student_screen.dart';

class _LockedDragResult extends StatelessWidget {
  final LiveCorrectAnswer correctAnswer;
  const _LockedDragResult({required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final order = correctAnswer.correctOrder ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: Column(
        children: order.asMap().entries.map((e) {
          final isLast = e.key == order.length - 1;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : const Border(
                      bottom: BorderSide(
                          color: AppColors.liveDarkBorder, width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${e.key + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: green,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    e.value,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

