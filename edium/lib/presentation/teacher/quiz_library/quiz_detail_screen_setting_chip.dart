part of 'quiz_detail_screen.dart';

class _SettingChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;

  const _SettingChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFFEE2E2) : AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color:
              highlight ? AppColors.error.withAlpha(80) : AppColors.mono100,
          width: AppDimens.borderWidth,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: highlight ? AppColors.error : AppColors.mono400,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: highlight ? AppColors.error : AppColors.mono700,
            ),
          ),
        ],
      ),
    );
  }
}

