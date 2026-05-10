part of 'teacher_home_screen.dart';

class _AwaitingReviewCard extends StatelessWidget {
  final AwaitingReviewSession session;

  const _AwaitingReviewCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final total = session.gradingCount + session.gradedCount + session.completedCount;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: () => context.push(
          '/teacher/review/${session.sessionId}',
          extra: {'quizTitle': session.quizTitle},
        ),
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                session.quizTitle,
                style: AppTextStyles.fieldText.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _StatusChip(
                    label: 'к проверке',
                    count: session.gradedCount,
                    active: session.gradedCount > 0,
                  ),
                  const SizedBox(width: 6),
                  _StatusChip(
                    label: 'у ИИ',
                    count: session.gradingCount,
                    active: false,
                  ),
                  const SizedBox(width: 6),
                  _StatusChip(
                    label: 'готово',
                    count: session.completedCount,
                    active: false,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: total > 0 ? session.completedCount / total : 0,
                  minHeight: 3,
                  backgroundColor: AppColors.mono100,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.mono700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

