part of 'create_quiz_screen.dart';

class _LibraryButton extends StatelessWidget {
  final bool canSubmit;
  final bool isSubmitting;
  final Future<void> Function() onPressed;

  const _LibraryButton({
    required this.canSubmit,
    required this.isSubmitting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: canSubmit ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mono900,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.mono200,
          disabledForegroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          textStyle: AppTextStyles.primaryButton,
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text('Создать шаблон'),
      ),
    );
  }
}

