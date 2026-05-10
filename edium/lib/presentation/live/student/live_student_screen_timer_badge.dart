part of 'live_student_screen.dart';

class _TimerBadge extends StatefulWidget {
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _TimerBadge({
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  State<_TimerBadge> createState() => _TimerBadgeState();
}

class _TimerBadgeState extends State<_TimerBadge> {
  late int _secondsLeft;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _secondsLeft = _computeSeconds();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _secondsLeft = _computeSeconds());
    });
  }

  int _computeSeconds() =>
      widget.deadlineAt.difference(DateTime.now()).inSeconds
          .clamp(0, widget.timeLimitSec);

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUrgent = _secondsLeft <= 5;
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    final label = _secondsLeft >= 60
        ? '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '$_secondsLeft с';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUrgent ? AppColors.liveAccent : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isUrgent ? Colors.white : AppColors.liveDarkBg,
          letterSpacing: 0.8,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

