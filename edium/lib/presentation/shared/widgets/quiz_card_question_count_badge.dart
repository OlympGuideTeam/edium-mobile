part of 'quiz_card.dart';

class _QuestionCountBadge extends StatelessWidget {
  final int count;
  const _QuestionCountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 ВОПРОС' : '$count ВОПРОСОВ';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.mono400,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

