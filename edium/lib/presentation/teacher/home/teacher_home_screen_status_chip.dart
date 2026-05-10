part of 'teacher_home_screen.dart';

class _StatusChip extends StatelessWidget {
  final String label;
  final int count;
  final bool active;

  const _StatusChip({
    required this.label,
    required this.count,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.mono900 : AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        '$count $label',
        style: AppTextStyles.helperText.copyWith(
          color: active ? Colors.white : AppColors.mono400,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

