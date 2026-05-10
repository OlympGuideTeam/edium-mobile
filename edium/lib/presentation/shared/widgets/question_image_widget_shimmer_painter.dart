part of 'question_image_widget.dart';

class _ShimmerPainter extends CustomPainter {
  final double progress;
  final Color base;
  final Color highlight;

  const _ShimmerPainter({
    required this.progress,
    required this.base,
    required this.highlight,
  });

  @override
  void paint(Canvas canvas, Size size) {

    canvas.drawRect(Offset.zero & size, Paint()..color = base);


    const stripeFraction = 0.30;
    final stripeW = size.width * stripeFraction;
    final startX = -stripeW + (size.width + stripeW) * progress;

    final gradient = LinearGradient(
      colors: [
        base.withAlpha(0),
        highlight.withAlpha(230),
        base.withAlpha(0),
      ],
      stops: const [0.0, 0.5, 1.0],
    ).createShader(Rect.fromLTWH(startX, 0, stripeW, size.height));

    canvas.drawRect(
      Rect.fromLTWH(startX, 0, stripeW, size.height),
      Paint()..shader = gradient,
    );
  }

  @override
  bool shouldRepaint(_ShimmerPainter old) =>
      old.progress != progress || old.base != base || old.highlight != highlight;
}

