part of 'live_teacher_screen.dart';

class _LiveDot extends StatefulWidget {
  final bool isLocked;
  const _LiveDot({required this.isLocked});

  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLocked) {
      return Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: AppColors.mono400, shape: BoxShape.circle),
      );
    }
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: AppColors.liveAccent.withValues(alpha: 0.4 + 0.6 * _anim.value),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.liveAccent.withValues(alpha: 0.3 * _anim.value),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

