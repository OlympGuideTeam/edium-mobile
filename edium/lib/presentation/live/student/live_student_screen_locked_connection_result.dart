part of 'live_student_screen.dart';

class _LockedConnectionResult extends StatelessWidget {
  final LiveCorrectAnswer correctAnswer;
  const _LockedConnectionResult({required this.correctAnswer});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final pairs = correctAnswer.correctPairs ?? {};

    return Container(
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.liveDarkBorder),
      ),
      child: Column(
        children: pairs.entries.toList().asMap().entries.map((e) {
          final isLast = e.key == pairs.length - 1;
          final entry = e.value;
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
                Expanded(
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.arrow_forward_rounded,
                      size: 16, color: green),
                ),
                Expanded(
                  child: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
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

