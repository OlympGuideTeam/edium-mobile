part of 'create_quiz_screen.dart';

class _AddQuestionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddQuestionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: AppColors.mono200, style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add, size: 18, color: AppColors.mono700),
            const SizedBox(width: 6),
            Text(
              'Добавить вопрос',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.mono700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

