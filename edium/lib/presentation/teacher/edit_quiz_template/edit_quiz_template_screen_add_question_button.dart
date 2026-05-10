part of 'edit_quiz_template_screen.dart';

class _AddQuestionButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddQuestionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mono200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
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

