part of 'student_quiz_library_screen.dart';

class _ErrorBody extends StatelessWidget {
  final StudentQuizError state;
  const _ErrorBody({required this.state});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.mono200, size: 48),
            const SizedBox(height: 12),
            Text(state.message,
                style: AppTextStyles.screenSubtitle,
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => context
                    .read<StudentQuizBloc>()
                    .add(const LoadStudentQuizzesEvent()),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.mono150),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  'Попробовать снова',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mono700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

