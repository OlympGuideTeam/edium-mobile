part of 'live_student_screen.dart';

class _LockedArrowPainter extends CustomPainter {
  final List<({Rect fromRect, Rect toRect, bool isCorrect})> arrows;
  const _LockedArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    if (arrows.isEmpty) return;
    const green = Color(0xFF22C55E);

    for (final a in arrows) {
      final paint = Paint()
        ..color = a.isCorrect ? green : Colors.redAccent
        ..strokeWidth = a.isCorrect ? 2.0 : 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final from = Offset(a.fromRect.right, a.fromRect.center.dy);
      final to = Offset(a.toRect.left, a.toRect.center.dy);
      if ((to - from).distance < 4) continue;
      final dx = (to.dx - from.dx) * 0.5;
      final path = Path()..moveTo(from.dx, from.dy);
      path.cubicTo(
          from.dx + dx, from.dy, to.dx - dx, to.dy, to.dx, to.dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LockedArrowPainter old) => old.arrows != arrows;
}

