part of 'live_student_screen.dart';

class _BinaryBar extends StatelessWidget {
  final String label;
  final int count;
  final double pct;
  final Color fillColor;
  final Color trackColor;
  final TextStyle labelStyle;
  final TextStyle countStyle;

  const _BinaryBar({
    required this.label,
    required this.count,
    required this.pct,
    required this.fillColor,
    required this.trackColor,
    required this.labelStyle,
    required this.countStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(label, style: labelStyle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: trackColor),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 400),
                      widthFactor: pct.clamp(0.0, 1.0),
                      heightFactor: 1.0,
                      child: ColoredBox(color: fillColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 28,
          child: Text(
            '$count',
            style: countStyle,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

