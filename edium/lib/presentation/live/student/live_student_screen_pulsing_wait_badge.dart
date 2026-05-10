part of 'live_student_screen.dart';

class _PulsingWaitBadge extends StatefulWidget {
  final String text;
  const _PulsingWaitBadge({this.text = 'Ожидайте начала квиза'});

  @override
  State<_PulsingWaitBadge> createState() => _PulsingWaitBadgeState();
}

class _PulsingWaitBadgeState extends State<_PulsingWaitBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.5, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.liveDarkSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          widget.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.liveDarkMuted,
            fontSize: 14,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}

