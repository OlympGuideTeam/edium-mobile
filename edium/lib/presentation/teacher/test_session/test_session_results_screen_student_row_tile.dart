part of 'test_session_results_screen.dart';

class _StudentRowTile extends StatelessWidget {
  final StudentRow row;
  final VoidCallback? onTap;
  const _StudentRowTile({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final attempt = row.attempt;
    final status = attempt?.status;
    final score = attempt?.score;
    final isPublished = status == AttemptStatus.published;
    final tappable = onTap != null;
    final needsAction = status == AttemptStatus.graded;
    final isInactive = status == null;


    final scoreText = (!isPublished && score != null)
        ? score.toStringAsFixed(0)
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: needsAction ? AppColors.mono25 : Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(
              color: needsAction ? AppColors.mono300 : AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: status, score: score),
                  const Spacer(),
                  if (scoreText != null) ...[
                    Text(
                      scoreText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono900,
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],
                  if (tappable)
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: needsAction ? AppColors.mono400 : AppColors.mono300,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                row.displayName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isInactive ? AppColors.mono400 : AppColors.mono900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

