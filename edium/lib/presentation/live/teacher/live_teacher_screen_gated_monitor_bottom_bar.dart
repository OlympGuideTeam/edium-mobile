part of 'live_teacher_screen.dart';

class _GatedMonitorBottomBar extends StatefulWidget {
  final bool isLast;
  final DateTime deadlineAt;
  final int timeLimitSec;
  final int answeredCount;
  final int totalCount;
  final VoidCallback onNext;

  const _GatedMonitorBottomBar({
    super.key,
    required this.isLast,
    required this.deadlineAt,
    required this.timeLimitSec,
    required this.answeredCount,
    required this.totalCount,
    required this.onNext,
  });

  @override
  State<_GatedMonitorBottomBar> createState() => _GatedMonitorBottomBarState();
}

class _GatedMonitorBottomBarState extends State<_GatedMonitorBottomBar> {
  Timer? _timer;

  bool _canProceed() {
    final hasTimer = widget.timeLimitSec > 0;
    final timeEnded = hasTimer && !DateTime.now().isBefore(widget.deadlineAt);
    final allAnswered =
        widget.totalCount > 0 && widget.answeredCount >= widget.totalCount;
    return timeEnded || allAnswered;
  }

  void _syncTimer() {
    if (_canProceed()) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_canProceed()) {
        _timer?.cancel();
        _timer = null;
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _GatedMonitorBottomBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MonitorBottomBar(
      isLast: widget.isLast,
      onNext: _canProceed() ? widget.onNext : null,
    );
  }
}

