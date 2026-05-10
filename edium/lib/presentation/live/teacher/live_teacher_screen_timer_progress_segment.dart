part of 'live_teacher_screen.dart';

class _TimerProgressSegment extends StatefulWidget {
  final EdgeInsets margin;
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _TimerProgressSegment({
    required this.margin,
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  State<_TimerProgressSegment> createState() => _TimerProgressSegmentState();
}

class _TimerProgressSegmentState extends State<_TimerProgressSegment>
    with SingleTickerProviderStateMixin {
  Ticker? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) {
      if (mounted) setState(() {});
    })..start();
  }

  @override
  void dispose() {
    _ticker?.dispose();
    super.dispose();
  }

  double get _fraction {
    if (widget.timeLimitSec <= 0) return 1.0;
    final totalMs = widget.timeLimitSec * 1000;
    final started = widget.deadlineAt
        .subtract(Duration(seconds: widget.timeLimitSec));
    final elapsedMs = DateTime.now().difference(started).inMilliseconds;
    return (elapsedMs / totalMs).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return _monitorSegmentTrack(
      margin: widget.margin,
      widthFactor: _fraction,
      fillColor: AppColors.liveAccent,
    );
  }
}

