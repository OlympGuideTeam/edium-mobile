part of 'create_quiz_screen.dart';

class _CourseContextButtons extends StatelessWidget {
  final bool canSave;
  final bool canPublish;
  final bool isSubmitting;
  final Future<void> Function() onSave;
  final Future<void> Function() onStart;

  const _CourseContextButtons({
    required this.canSave,
    required this.canPublish,
    required this.isSubmitting,
    required this.onSave,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: AppDimens.buttonH,
            child: OutlinedButton(
              onPressed: canSave ? onSave : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mono900,
                disabledForegroundColor: AppColors.mono300,
                side: BorderSide(
                  color:
                      canSave ? AppColors.mono300 : AppColors.mono150,
                ),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusLg),
                ),
                textStyle: AppTextStyles.primaryButton,
              ),
              child: const Text('Сохранить'),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: AppDimens.buttonH,
            child: ElevatedButton(
              onPressed: canPublish ? onStart : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mono900,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.mono200,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimens.radiusLg),
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
                  : const Text('Начать'),
            ),
          ),
        ),
      ],
    );
  }
}

