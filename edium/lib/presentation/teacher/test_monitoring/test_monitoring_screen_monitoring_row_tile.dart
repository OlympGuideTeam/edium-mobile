part of 'test_monitoring_screen.dart';

class _MonitoringRowTile extends StatelessWidget {
  final MonitoringRow row;
  final bool needsManualGrading;
  final VoidCallback? onTap;

  const _MonitoringRowTile({
    required this.row,
    required this.needsManualGrading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tappable = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: AppColors.mono150,
            width: AppDimens.borderWidth,
          ),
        ),
        child: Row(
          children: [
            _Avatar(name: row.displayName),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                row.displayName,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mono900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            _TrailingSection(row: row, needsManualGrading: needsManualGrading),
            if (tappable) ...[
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right,
                  size: 18, color: AppColors.mono300),
            ],
          ],
        ),
      ),
    );
  }
}

