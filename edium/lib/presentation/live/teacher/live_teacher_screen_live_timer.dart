part of 'live_teacher_screen.dart';

class _LiveTimer extends StatefulWidget {
  final DateTime deadlineAt;
  const _LiveTimer({required this.deadlineAt});

  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  late int _secondsLeft;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(_tick);
    });
  }

  void _tick() {
    _secondsLeft =
        widget.deadlineAt.difference(DateTime.now()).inSeconds.clamp(0, 99999);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final m = _secondsLeft ~/ 60;
    final s = _secondsLeft % 60;
    final label = _secondsLeft >= 60
        ? '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}'
        : '$_secondsLeft с';
    final urgent = _secondsLeft <= 10;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: urgent ? AppColors.liveAccent : AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.8,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

