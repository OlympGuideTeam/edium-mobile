part of 'courses_screen.dart';

class _ScoreBadge extends StatelessWidget {
  final String score;
  const _ScoreBadge({required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline,
              size: 11, color: AppColors.mono600),
          const SizedBox(width: 3),
          Text(
            score,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.mono600,
            ),
          ),
        ],
      ),
    );
  }
}

