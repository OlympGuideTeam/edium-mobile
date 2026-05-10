part of 'review_session_screen.dart';

class _AttemptTile extends StatelessWidget {
  final AttemptSummary attempt;
  final VoidCallback? onTap;

  const _AttemptTile({required this.attempt, required this.onTap});

  Widget _trailingIcon(AttemptStatus status) {
    if (status == AttemptStatus.graded) {
      return const Icon(Icons.chevron_right, color: AppColors.mono400);
    }
    if (status == AttemptStatus.grading) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          color: AppColors.mono300,
          strokeWidth: 2,
        ),
      );
    }
    if (status == AttemptStatus.completed) {
      return const Icon(
        Icons.check_circle_outline,
        color: AppColors.mono400,
        size: 20,
      );
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    final isGraded = attempt.status == AttemptStatus.graded;
    final isCompleted = attempt.status == AttemptStatus.completed;
    final name = attempt.userName?.isNotEmpty == true
        ? attempt.userName!
        : attempt.userId;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimens.radiusLg),
            border: Border.all(
              color: AppColors.mono150,
              width: AppDimens.borderWidth,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.fieldText.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGraded
                          ? 'Ждёт проверки учителя'
                          : isCompleted
                              ? 'Проверено'
                              : 'Проверяет ИИ',
                      style: AppTextStyles.helperText.copyWith(
                        color: isGraded
                            ? AppColors.mono600
                            : isCompleted
                                ? AppColors.mono400
                                : AppColors.mono300,
                      ),
                    ),
                  ],
                ),
              ),
              _trailingIcon(attempt.status),
            ],
          ),
        ),
      ),
    );
  }
}

