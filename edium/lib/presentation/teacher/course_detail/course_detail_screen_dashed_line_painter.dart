part of 'course_detail_screen.dart';

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.mono200
      ..strokeWidth = 1;
    const dashW = 5.0;
    const gapW = 4.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(math.min(x + dashW, size.width), 0),
        paint,
      );
      x += dashW + gapW;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => false;
}

