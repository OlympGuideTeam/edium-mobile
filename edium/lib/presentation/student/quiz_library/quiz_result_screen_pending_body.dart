part of 'quiz_result_screen.dart';

class _PendingBody extends StatelessWidget {
  const _PendingBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: AppDimens.screenPaddingH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.mono50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.mono150),
              ),
              child: const Icon(Icons.auto_awesome_outlined,
                  size: 28, color: AppColors.mono600),
            ),
            const SizedBox(height: 18),
            const Text('Ответы проверяются', style: AppTextStyles.screenTitle),
            const SizedBox(height: 8),
            Text(
              'Часть ответов проверяется ИИ или учителем. Экран обновится автоматически.',
              style: AppTextStyles.screenSubtitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

