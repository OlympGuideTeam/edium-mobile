part of 'edit_quiz_template_screen.dart';

class _BottomBar extends StatelessWidget {
  final bool canSave;
  final bool submitting;
  final VoidCallback onSave;

  const _BottomBar({
    required this.canSave,
    required this.submitting,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.mono100)),
      ),
      child: SizedBox(
        height: AppDimens.buttonH,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: canSave ? onSave : null,
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
          child: submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Сохранить'),
        ),
      ),
    );
  }
}

