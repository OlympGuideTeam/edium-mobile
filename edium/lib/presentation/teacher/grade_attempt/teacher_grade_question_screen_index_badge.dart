part of 'teacher_grade_question_screen.dart';

class _IndexBadge extends StatelessWidget {
  final int index;
  const _IndexBadge({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '$index',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.mono600,
          ),
        ),
      ),
    );
  }
}

