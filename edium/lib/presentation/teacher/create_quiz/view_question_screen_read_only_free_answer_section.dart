part of 'view_question_screen.dart';

class _ReadOnlyFreeAnswerSection extends StatelessWidget {
  const _ReadOnlyFreeAnswerSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mono100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.edit_outlined,
                size: 20, color: AppColors.mono400),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Свободный ответ',
                  style: AppTextStyles.bodySmall
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Студент пишет текст произвольной формы. Проверяется учителем вручную.',
                  style: AppTextStyles.helperText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

