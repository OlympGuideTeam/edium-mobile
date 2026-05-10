part of 'student_question_review_sheet.dart';

class _TeacherGradeBlock extends StatelessWidget {
  final double? score;
  final int maxScore;
  final String? feedback;

  const _TeacherGradeBlock({
    required this.score,
    required this.maxScore,
    required this.feedback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.mono150),
          ),
          child: Row(
            children: [
              const Text('Балл', style: AppTextStyles.fieldLabel),
              const Spacer(),
              if (score != null)
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: score!.toStringAsFixed(
                            score! % 1 == 0 ? 0 : 1),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.mono900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      TextSpan(
                        text: ' / $maxScore',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.mono300,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Text('—',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.mono300)),
            ],
          ),
        ),
        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusMd),
            border: Border.all(color: AppColors.mono150),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Комментарий', style: AppTextStyles.fieldLabel),
              const SizedBox(height: 8),
              if (feedback != null && feedback!.isNotEmpty)
                Text(
                  feedback!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.mono700,
                    height: 1.5,
                  ),
                )
              else
                Row(
                  children: const [
                    Icon(Icons.chat_bubble_outline,
                        size: 14, color: AppColors.mono300),
                    SizedBox(width: 8),
                    Text(
                      'Комментарий не добавлен',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.mono300,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

