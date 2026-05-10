part of 'student_home_screen.dart';

class _GradeRow extends StatelessWidget {
  final RecentGradeItem item;

  const _GradeRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.quizTitle,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.mono700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _scoreText,
            style: TextStyle(
              fontSize: 13,
              fontWeight:
                  item.score != null ? FontWeight.w700 : FontWeight.w400,
              color: item.score != null
                  ? AppColors.mono900
                  : AppColors.mono400,
            ),
          ),
        ],
      ),
    );
  }

  String get _scoreText {
    if (item.score != null) return item.score!.toStringAsFixed(1);
    return switch (item.status) {
      'grading' => 'Проверяется',
      'graded' => 'Будет позже',
      _ => '—',
    };
  }
}

