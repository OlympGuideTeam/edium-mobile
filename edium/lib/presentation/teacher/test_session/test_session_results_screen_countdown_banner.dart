part of 'test_session_results_screen.dart';

class _CountdownBanner extends StatefulWidget {
  final String label;
  final DateTime target;
  final String? subtitle;
  final VoidCallback? onExpired;

  const _CountdownBanner({
    required this.label,
    required this.target,
    this.subtitle,
    this.onExpired,
  });

  @override
  State<_CountdownBanner> createState() => _CountdownBannerState();
}

class _CountdownBannerState extends State<_CountdownBanner> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    final remaining = widget.target.toLocal().difference(DateTime.now());
    if (remaining.isNegative) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onExpired?.call();
      });
      return;
    }

    if (remaining.inSeconds < 60) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final r = widget.target.toLocal().difference(DateTime.now());
        setState(() {});
        if (r.isNegative) {
          _timer?.cancel();
          widget.onExpired?.call();
        }
      });
    } else {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        if (!mounted) return;
        setState(() {});
        final r = widget.target.toLocal().difference(DateTime.now());
        if (r.isNegative) {
          _timer?.cancel();
          widget.onExpired?.call();
        } else if (r.inSeconds < 60) {
          _startTimer();
        }
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
    final diff = widget.target.toLocal().difference(now);
    if (diff.isNegative) return const SizedBox.shrink();

    final isUnderMinute = diff.inSeconds < 60;
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

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
          Text(
            widget.label,
            style: const TextStyle(
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
          if (widget.subtitle != null) ...[
            const SizedBox(height: 10),
            Text(
              widget.subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0x80FFFFFF),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

