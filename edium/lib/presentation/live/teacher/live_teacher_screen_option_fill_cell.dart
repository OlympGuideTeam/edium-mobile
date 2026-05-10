part of 'live_teacher_screen.dart';

class _OptionFillCell extends StatelessWidget {
  final String text;
  final double fillFraction;
  final int count;
  final bool isCorrect;
  final bool isMulti;
  final bool showCount;

  const _OptionFillCell({
    required this.text,
    required this.fillFraction,
    required this.count,
    required this.isCorrect,
    required this.isMulti,
    required this.showCount,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isCorrect ? AppColors.mono900 : AppColors.mono150;


    const borderWidth = 1.5;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: borderWidth),
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
                        ? const Color(0xFF22C55E).withValues(alpha: 0.12)
                        : AppColors.mono100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                _ChoiceIndicator(isCorrect: isCorrect, isMulti: isMulti),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isCorrect ? AppColors.mono900 : AppColors.mono700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        showCount ? '${(fillFraction * 100).round()}%' : '—',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: showCount
                              ? (isCorrect ? const Color(0xFF22C55E) : AppColors.mono600)
                              : AppColors.mono200,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      Visibility(
                        visible: showCount,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.mono400,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
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

