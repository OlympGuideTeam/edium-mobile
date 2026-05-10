part of 'live_student_screen.dart';

class _TimerProgressBar extends StatefulWidget {
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _TimerProgressBar({
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  State<_TimerProgressBar> createState() => _TimerProgressBarState();
}

class _TimerProgressBarState extends State<_TimerProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    final totalMs = widget.timeLimitSec > 0 ? widget.timeLimitSec * 1000 : 1;
    final started =
        widget.deadlineAt.subtract(Duration(seconds: widget.timeLimitSec));
    final elapsedMs =
        DateTime.now().difference(started).inMilliseconds.clamp(0, totalMs);
    final remainingMs = totalMs - elapsedMs;
    final startFraction = (elapsedMs / totalMs).clamp(0.0, 1.0);

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: remainingMs),
    );
    _anim = Tween<double>(begin: startFraction, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
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
      builder: (_, __) {
        final urgent = _anim.value >= 0.85;
        final fillColor =
            urgent ? Colors.redAccent : AppColors.liveAccent;
        return Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.liveDarkCard,
            borderRadius: BorderRadius.circular(999),
          ),
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: _anim.value,
              heightFactor: 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

