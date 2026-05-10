part of 'take_quiz_screen.dart';

class _ConnectionArrowPainter extends CustomPainter {
  final List<({Rect fromRect, Rect toRect, String leftItem})> arrows;

  _ConnectionArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    if (arrows.isEmpty) return;

    const color = AppColors.mono700;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final arrow in arrows) {
      final from = Offset(arrow.fromRect.right, arrow.fromRect.center.dy);
      final to = Offset(arrow.toRect.left, arrow.toRect.center.dy);

      if ((to - from).distance < 4) continue;

      canvas.drawPath(_buildSCurvePath(from, to), linePaint);
    }
  }


  Path _buildSCurvePath(Offset from, Offset to) {
    final path = Path()..moveTo(from.dx, from.dy);
    final dx = (to.dx - from.dx) * 0.5;
    path.cubicTo(
      from.dx + dx, from.dy,
      to.dx - dx, to.dy,
      to.dx, to.dy,
    );
    return path;
  }

  @override
  bool shouldRepaint(_ConnectionArrowPainter old) => old.arrows != arrows;
}

