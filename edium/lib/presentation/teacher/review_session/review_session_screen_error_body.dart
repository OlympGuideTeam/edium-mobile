part of 'review_session_screen.dart';

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Не удалось загрузить попытки',
              style: AppTextStyles.screenSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: const Text(
                'Повторить',
                style: TextStyle(color: AppColors.mono900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

