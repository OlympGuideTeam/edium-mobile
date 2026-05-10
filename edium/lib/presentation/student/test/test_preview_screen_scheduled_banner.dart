part of 'test_preview_screen.dart';

class _ScheduledBanner extends StatefulWidget {
  final DateTime startTime;
  final int? durationSec;

  const _ScheduledBanner({required this.startTime, this.durationSec});

  @override
  State<_ScheduledBanner> createState() => _ScheduledBannerState();
}

class _ScheduledBannerState extends State<_ScheduledBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final remaining = widget.startTime.toLocal().difference(DateTime.now());
    if (remaining.isNegative) return;

    if (remaining.inSeconds < 60) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
        final r = widget.startTime.toLocal().difference(DateTime.now());
        if (r.inSeconds < 60) _startTimer();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final diff = widget.startTime.toLocal().difference(now);
    if (diff.isNegative) return const SizedBox.shrink();

    final isUnderMinute = diff.inSeconds < 60;
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    final start = widget.startTime.toLocal();
    const ruWeekdays = [
      '',
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    const ruMonths = [
      '',
      'янв',
      'фев',
      'мар',
      'апр',
      'май',
      'июн',
      'июл',
      'авг',
      'сен',
      'окт',
      'ноя',
      'дек',
    ];

    final weekday = ruWeekdays[start.weekday];
    final dateStr = '${start.day} ${ruMonths[start.month]}';
    final timeStr =
        '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';

    final subParts = ['$weekday, $dateStr · $timeStr'];
    if (widget.durationSec != null && widget.durationSec! > 0) {
      final min = (widget.durationSec! / 60).round();
      subParts.add('длительность ≈ $min мин');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'СТАРТ ЧЕРЕЗ',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0x80FFFFFF),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (isUnderMinute) ...[
                _CountUnit(
                  value: seconds.toString().padLeft(2, '0'),
                  unit: 'сек',
                ),
              ] else ...[
                if (days > 0) ...[
                  _CountUnit(
                    value: days.toString().padLeft(2, '0'),
                    unit: 'дн',
                  ),
                  const SizedBox(width: 14),
                ],
                _CountUnit(
                  value: hours.toString().padLeft(2, '0'),
                  unit: 'ч',
                ),
                const SizedBox(width: 14),
                _CountUnit(
                  value: minutes.toString().padLeft(2, '0'),
                  unit: 'мин',
                ),
              ],
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subParts.join(' · '),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0x80FFFFFF),
            ),
          ),
        ],
      ),
    );
  }
}

