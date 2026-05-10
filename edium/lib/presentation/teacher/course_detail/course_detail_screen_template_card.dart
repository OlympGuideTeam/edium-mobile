part of 'course_detail_screen.dart';

class _TemplateCard extends StatelessWidget {
  final Quiz quiz;
  final VoidCallback onTap;

  const _TemplateCard({required this.quiz, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(
            color: AppColors.mono150,
            width: AppDimens.borderWidth,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.mono100,
                borderRadius: BorderRadius.circular(AppDimens.radiusSm),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: AppColors.mono600,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (quiz.description != null &&
                      quiz.description!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      quiz.description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mono400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.mono100,
                      borderRadius: BorderRadius.circular(AppDimens.radiusXs),
                    ),
                    child: Text(
                      '${quiz.questionsCount} вопр.',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.mono600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.mono300,
            ),
          ],
        ),
      ),
    );
  }
}

