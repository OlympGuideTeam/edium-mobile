part of 'teacher_grade_attempt_screen.dart';

class _SubmitButton extends StatelessWidget {
  final bool isSaving;
  final bool isReady;
  final VoidCallback onTap;

  const _SubmitButton({
    required this.isSaving,
    required this.isReady,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = isReady && !isSaving;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPaddingH, 8, AppDimens.screenPaddingH, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isReady && !isSaving)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Оцените все вопросы с развёрнутым ответом',
                style: AppTextStyles.caption.copyWith(color: AppColors.mono400),
                textAlign: TextAlign.center,
              ),
            ),
          SizedBox(
            width: double.infinity,
            height: AppDimens.buttonH,
            child: ElevatedButton(
              onPressed: enabled ? onTap : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mono900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.mono200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
                elevation: 0,
                textStyle: AppTextStyles.primaryButton,
              ),
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Завершить проверку'),
            ),
          ),
        ],
      ),
    );
  }
}

