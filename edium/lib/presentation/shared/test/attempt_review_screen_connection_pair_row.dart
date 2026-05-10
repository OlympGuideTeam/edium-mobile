part of 'attempt_review_screen.dart';

class _ConnectionPairRow extends StatelessWidget {
  final String left;
  final String studentRight;
  final String? correctRight;
  final bool? isCorrect;
  final bool dark;

  static const _green = Color(0xFF22C55E);
  static const _red = Color(0xFFEF4444);

  const _ConnectionPairRow({
    required this.left,
    required this.studentRight,
    this.correctRight,
    required this.isCorrect,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor;
    final Color bgColor;
    final Color borderColor;

    if (isCorrect == true) {
      accentColor = _green;
      bgColor = dark
          ? const Color(0xFF22C55E).withValues(alpha: 0.08)
          : const Color(0xFFE8F5E9);
      borderColor = _green.withValues(alpha: 0.4);
    } else if (isCorrect == false) {
      accentColor = _red;
      bgColor = dark
          ? const Color(0xFFEF4444).withValues(alpha: 0.08)
          : const Color(0xFFFEE2E2);
      borderColor = _red.withValues(alpha: 0.4);
    } else {
      accentColor = dark ? Colors.white54 : AppColors.mono400;
      bgColor = dark ? Colors.white.withValues(alpha: 0.05) : AppColors.mono50;
      borderColor = dark ? Colors.white.withValues(alpha: 0.12) : AppColors.mono150;
    }

    final textColor = dark ? Colors.white : AppColors.mono900;
    final arrowColor = dark ? Colors.white30 : AppColors.mono300;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  left,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isCorrect != null ? accentColor : textColor,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward, size: 13, color: arrowColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  studentRight,
                  style: TextStyle(
                    fontSize: 13,
                    color: isCorrect != null ? accentColor : textColor,
                  ),
                ),
              ),
              if (isCorrect != null) ...[
                const SizedBox(width: 6),
                Icon(
                  isCorrect! ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: accentColor,
                ),
              ],
            ],
          ),
          if (isCorrect == false && correctRight != null) ...[
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.subdirectory_arrow_right, size: 13, color: AppColors.mono300),
                const SizedBox(width: 6),
                Text(
                  'Верно: $correctRight',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

