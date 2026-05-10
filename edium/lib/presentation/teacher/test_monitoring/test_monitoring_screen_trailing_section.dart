part of 'test_monitoring_screen.dart';

class _TrailingSection extends StatelessWidget {
  final MonitoringRow row;
  final bool needsManualGrading;

  const _TrailingSection({required this.row, required this.needsManualGrading});

  @override
  Widget build(BuildContext context) {
    final status = row.status;

    if (status == null) {
      return const _Chip(label: 'Не начинал', color: AppColors.mono250);
    }

    if (status == AttemptStatus.inProgress) {
      return const _Chip(label: 'В процессе', color: AppColors.mono600);
    }

    if (status == AttemptStatus.grading) {
      return const _Chip(label: 'Завершил', color: AppColors.mono300);
    }

    if (status == AttemptStatus.graded) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Chip(label: 'Завершил', color: AppColors.mono900),
          if (needsManualGrading) ...[
            const SizedBox(width: 6),
            const Icon(Icons.edit_outlined, size: 15, color: AppColors.mono400),
          ],
        ],
      );
    }


    final scoreText = row.score != null
        ? '${row.score!.toStringAsFixed(row.score! % 1 == 0 ? 0 : 1)}%'
        : '—';
    return Text(
      scoreText,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.mono900,
      ),
    );
  }
}

