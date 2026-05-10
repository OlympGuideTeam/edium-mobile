part of 'invite_screen.dart';

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.mono700,
          side: const BorderSide(color: AppColors.mono200, width: AppDimens.borderWidth),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
        ),
        child: Text(label, style: AppTextStyles.subtitle.copyWith(color: AppColors.mono700)),
      ),
    );
  }
}

