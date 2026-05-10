part of 'live_teacher_screen.dart';

class _LockedSnapSegment extends StatefulWidget {
  final EdgeInsets margin;
  final double fillStart;

  const _LockedSnapSegment({
    required this.margin,
    required this.fillStart,
  });

  @override
  State<_LockedSnapSegment> createState() => _LockedSnapSegmentState();
}

class _LockedSnapSegmentState extends State<_LockedSnapSegment>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _anim = Tween<double>(
      begin: widget.fillStart.clamp(0.0, 1.0),
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => _monitorSegmentTrack(
        margin: widget.margin,
        widthFactor: _anim.value,
        fillColor: AppColors.mono900,
      ),
    );
  }
}

