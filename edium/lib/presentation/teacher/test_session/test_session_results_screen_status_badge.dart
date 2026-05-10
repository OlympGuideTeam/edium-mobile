part of 'test_session_results_screen.dart';

class _StatusBadge extends StatelessWidget {
  final AttemptStatus? status;
  final double? score;
  const _StatusBadge({required this.status, this.score});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case null:
        return _chip('Не начал', AppColors.mono350, Colors.transparent, AppColors.mono150);
      case AttemptStatus.inProgress:
        return _chip('Проходит', AppColors.mono400, AppColors.mono50, AppColors.mono150);
      case AttemptStatus.grading:
        return _chip('Не оценено', AppColors.mono400, AppColors.mono50, AppColors.mono150);
      case AttemptStatus.graded:
        return _chip('Оценено ИИ', Colors.white, AppColors.mono900, AppColors.mono900);
      case AttemptStatus.completed:
        return _chip('Оценено Вами', AppColors.mono600, AppColors.mono50, AppColors.mono150);
      case AttemptStatus.published:
        return _GradeChip(score: score);
    }
  }

  Widget _chip(String label, Color textColor, Color bgColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
        border: Border.all(color: borderColor, width: AppDimens.borderWidth),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: textColor,
        ),
      ),
    );
  }
}

