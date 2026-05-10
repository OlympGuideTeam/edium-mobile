part of 'courses_screen.dart';

class _ItemTile extends StatelessWidget {
  final CourseItem item;

  const _ItemTile({required this.item});

  bool get _isTemplate => item.type == 'quiz_template';

  @override
  Widget build(BuildContext context) {
    final isPassed = item.isPassed;
    final scoreText = isPassed
        ? '${item.score!.toStringAsFixed(item.score! % 1 == 0 ? 0 : 1)}%'
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        children: [
          _TypeBadge(isTemplate: _isTemplate),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Квиз ${item.orderIndex + 1}',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.mono900,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          if (isPassed)
            _ScoreBadge(score: scoreText!)
          else
            const Text(
              'Не пройден',
              style: TextStyle(fontSize: 11, color: AppColors.mono300),
            ),
        ],
      ),
    );
  }
}

