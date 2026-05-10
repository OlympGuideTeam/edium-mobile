part of 'quiz_results_screen.dart';

class _StudentResultTile extends StatelessWidget {
  final Map<String, dynamic> result;

  const _StudentResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final score = result['score'] as int;
    final total = result['total'] as int;
    final pct = total > 0 ? (score / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryLight,
            child: Text(
              (result['name'] as String)[0],
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(result['name'] as String,
                    style: AppTextStyles.bodySmall
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('$score / $total вопросов',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: pct >= 70
                  ? AppColors.successLight
                  : AppColors.errorLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$pct%',
              style: AppTextStyles.caption.copyWith(
                color: pct >= 70 ? AppColors.success : AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

