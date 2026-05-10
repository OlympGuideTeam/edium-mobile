part of 'attempt_review_screen.dart';

class _OptionLine extends StatelessWidget {
  final String text;
  final bool isPicked;
  final bool isCorrect;

  const _OptionLine({
    required this.text,
    required this.isPicked,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isCorrect
        ? const Color(0xFFE8F5E9)
        : (isPicked ? const Color(0xFFFEE2E2) : Colors.white);
    final borderColor = isCorrect
        ? const Color(0xFF22C55E)
        : (isPicked ? const Color(0xFFEF4444) : AppColors.mono150);

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
            isPicked
                ? (isCorrect ? Icons.check_circle : Icons.cancel)
                : (isCorrect ? Icons.check : Icons.radio_button_unchecked),
            size: 16,
            color: isCorrect
                ? const Color(0xFF22C55E)
                : (isPicked ? const Color(0xFFEF4444) : AppColors.mono300),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.mono900)),
          ),
        ],
      ),
    );
  }
}

