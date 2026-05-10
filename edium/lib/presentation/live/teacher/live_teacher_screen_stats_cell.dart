part of 'live_teacher_screen.dart';

class _StatsCell extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final double? progress;
  final Color? valueColor;

  const _StatsCell({
    required this.label,
    required this.value,
    this.sub,
    this.progress,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.mono400,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.mono900,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (sub != null) ...[
                const SizedBox(width: 3),
                Text(
                  sub!,
                  style: const TextStyle(fontSize: 12, color: AppColors.mono400),
                ),
              ],
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                height: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: AppColors.mono100),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 300),
                        widthFactor: progress!.clamp(0.0, 1.0),
                        heightFactor: 1.0,
                        child: const ColoredBox(color: AppColors.mono900),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

