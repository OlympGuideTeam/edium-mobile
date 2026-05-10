part of 'live_teacher_screen.dart';

class _PendingRow extends StatefulWidget {
  final LiveLobbyParticipant participant;
  final DateTime questionStartedAt;
  final bool isLast;

  const _PendingRow({
    required this.participant,
    required this.questionStartedAt,
    required this.isLast,
  });

  @override
  State<_PendingRow> createState() => _PendingRowState();
}

class _PendingRowState extends State<_PendingRow> {
  int _elapsed = 0;
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
    _elapsed = DateTime.now().difference(widget.questionStartedAt).inSeconds.clamp(0, 99999);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ParticipantRow(
      name: widget.participant.name,
      isLast: widget.isLast,
      trailing: Text(
        'обдумывает… $_elapsed с',
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.mono400,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      dotColor: AppColors.mono300,
    );
  }
}

