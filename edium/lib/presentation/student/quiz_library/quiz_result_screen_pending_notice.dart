part of 'quiz_result_screen.dart';

class _PendingNotice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hourglass_top_outlined,
              size: 16, color: AppColors.mono400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Часть ответов ещё проверяется — итоговый балл может измениться.',
              style: AppTextStyles.helperText,
            ),
          ),
        ],
      ),
    );
  }
}


enum _AnswerStatus { correct, partial, wrong, pending }

