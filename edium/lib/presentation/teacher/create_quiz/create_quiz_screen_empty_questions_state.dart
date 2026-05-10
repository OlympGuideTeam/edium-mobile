part of 'create_quiz_screen.dart';

class _EmptyQuestionsState extends StatelessWidget {
  const _EmptyQuestionsState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mono100),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.quiz_outlined,
                size: 24, color: AppColors.mono400),
          ),
          const SizedBox(height: 12),
          Text(
            'Вопросов пока нет',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.mono700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Добавьте хотя бы один вопрос',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}

