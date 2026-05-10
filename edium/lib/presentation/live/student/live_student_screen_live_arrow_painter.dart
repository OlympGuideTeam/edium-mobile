part of 'live_student_screen.dart';

class _LiveArrowPainter extends CustomPainter {
  final List<({Rect fromRect, Rect toRect, String leftItem})> arrows;
  const _LiveArrowPainter({required this.arrows});

  @override
  void paint(Canvas canvas, Size size) {
    if (arrows.isEmpty) return;
    final paint = Paint()
      ..color = AppColors.liveDarkMuted
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final a in arrows) {
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
  bool shouldRepaint(_LiveArrowPainter old) => old.arrows != arrows;
}

