part of 'test_monitoring_screen.dart';

class _StatsStrip extends StatelessWidget {
  final int notStarted;
  final int inProgress;
  final int finished;

  const _StatsStrip({
    required this.notStarted,
    required this.inProgress,
    required this.finished,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150, width: AppDimens.borderWidth),
      ),
      child: Row(
        children: [
          _StatCell(value: '$notStarted', label: 'Не начали'),
          _Divider(),
          _StatCell(value: '$inProgress', label: 'Проходят'),
          _Divider(),
          _StatCell(value: '$finished', label: 'Завершили'),
        ],
      ),
    );
  }
}

