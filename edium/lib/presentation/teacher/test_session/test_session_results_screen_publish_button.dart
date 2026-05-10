part of 'test_session_results_screen.dart';

class _PublishButton extends StatelessWidget {
  final bool isPublishing;
  const _PublishButton({required this.isPublishing});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppDimens.buttonH,
      child: ElevatedButton(
        onPressed: isPublishing
            ? null
            : () {
                context
                    .read<TestSessionResultsBloc>()
                    .add(const PublishSessionEvent());
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.mono900,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
          ),
          textStyle: AppTextStyles.primaryButton,
        ),
        child: isPublishing
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : const Text('Опубликовать результаты'),
      ),
    );
  }
}

