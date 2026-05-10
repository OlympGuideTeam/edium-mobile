part of 'live_student_screen.dart';

class _LockedOptionFillCell extends StatelessWidget {
  final String text;
  final double fillFraction;
  final bool isCorrect;
  final bool isMulti;
  final bool isSelected;

  const _LockedOptionFillCell({
    required this.text,
    required this.fillFraction,
    required this.isCorrect,
    required this.isMulti,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final borderColor = isCorrect ? green : AppColors.liveDarkBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 400),
                widthFactor: fillFraction.clamp(0.0, 1.0),
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: isCorrect
                        ? green.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _LockedChoiceIndicator(
                    isCorrect: isCorrect, isMulti: isMulti, isSelected: isSelected),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isCorrect ? Colors.white : Colors.white70,
                      height: 1.4,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

