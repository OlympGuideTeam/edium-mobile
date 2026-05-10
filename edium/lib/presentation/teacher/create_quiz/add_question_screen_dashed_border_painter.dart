part of 'add_question_screen.dart';

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double strokeWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(radius),
      ));

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final pathMetrics = path.computeMetrics();
    for (final metric in pathMetrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) =>
      color != old.color ||
      radius != old.radius ||
      strokeWidth != old.strokeWidth;
}

Widget _dashedAddRowButton({
  required String label,
  required VoidCallback? onTap,
}) {
  final enabled = onTap != null;
  return GestureDetector(
    onTap: onTap,
    child: CustomPaint(
      painter: _DashedBorderPainter(
        color: enabled ? AppColors.mono300 : AppColors.mono200,
        radius: AppDimens.radiusLg,
        strokeWidth: AppDimens.borderWidth,
      ),
      child: Container(
        width: double.infinity,
        height: AppDimens.buttonHSm,
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.fieldText.copyWith(
            color: enabled ? AppColors.mono400 : AppColors.mono300,
          ),
        ),
      ),
    ),
  );
}

