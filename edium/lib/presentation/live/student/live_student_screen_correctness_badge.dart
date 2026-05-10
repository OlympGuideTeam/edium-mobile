part of 'live_student_screen.dart';

class _CorrectnessBadge extends StatelessWidget {
  final LiveStudentResult? myResult;
  const _CorrectnessBadge({required this.myResult});

  @override
  Widget build(BuildContext context) {
    if (myResult == null) {
      return Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.liveDarkCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.liveDarkBorder),
        ),
        child: const Text(
          'Нет ответа',
          style: TextStyle(
            color: AppColors.liveDarkMuted,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    const green = Color(0xFF22C55E);
    final isCorrect = myResult!.isCorrect;
    final color = isCorrect ? green : Colors.redAccent;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCorrect ? Icons.check_rounded : Icons.close_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            isCorrect ? 'Верно' : 'Неверно',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

