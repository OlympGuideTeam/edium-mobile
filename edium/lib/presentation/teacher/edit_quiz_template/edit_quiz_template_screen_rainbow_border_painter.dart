part of 'edit_quiz_template_screen.dart';

class _RainbowBorderPainter extends CustomPainter {
  final double progress;
  final double borderRadius;
  final double borderWidth;

  _RainbowBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final inset = borderWidth / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - borderWidth,
      size.height - borderWidth,
    );
    final r = borderRadius <= inset ? 0.0 : borderRadius - inset;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));

    final colors = [
      const Color(0xFFFF0000),
      const Color(0xFFFF8000),
      const Color(0xFFFFFF00),
      const Color(0xFF00FF00),
      const Color(0xFF00FFFF),
      const Color(0xFF0080FF),
      const Color(0xFF8000FF),
      const Color(0xFFFF00FF),
      const Color(0xFFFF0000),
    ];

    final sweepGradient = SweepGradient(
      startAngle: 0,
      endAngle: math.pi * 2,
      colors: colors,
      transform: GradientRotation(progress * math.pi * 2),
    );

    final paint = Paint()
      ..shader = sweepGradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_RainbowBorderPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

