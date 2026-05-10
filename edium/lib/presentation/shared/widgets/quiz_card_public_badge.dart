part of 'quiz_card.dart';

class _PublicBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.mono900,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: const Text(
        'ПУБЛИЧНЫЙ',
        style: AppTextStyles.badgeText,
      ),
    );
  }
}

