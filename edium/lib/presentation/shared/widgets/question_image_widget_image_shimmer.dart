part of 'question_image_widget.dart';

class _ImageShimmer extends StatefulWidget {
  final bool dark;
  const _ImageShimmer({this.dark = false});

  @override
  State<_ImageShimmer> createState() => _ImageShimmerState();
}

class _ImageShimmerState extends State<_ImageShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    _anim = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = widget.dark ? const Color(0xFF1A1A2A) : const Color(0xFFE8E8E8);
    final highlight = widget.dark ? const Color(0xFF3A3A5A) : const Color(0xFFFFFFFF);

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: _kShimmerHeight,
          child: CustomPaint(
            painter: _ShimmerPainter(
              progress: _anim.value,
              base: base,
              highlight: highlight,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

