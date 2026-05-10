part of 'quiz_detail_screen.dart';

class _QuestionTypeBadge extends StatelessWidget {
  final QuestionType type;
  const _QuestionTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _label(type),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.mono400,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  String _label(QuestionType type) {
    switch (type) {
      case QuestionType.singleChoice:
        return 'Один ответ';
      case QuestionType.multiChoice:
        return 'Несколько ответов';
      case QuestionType.withFreeAnswer:
        return 'Свободный ответ';
      case QuestionType.withGivenAnswer:
        return 'Данный ответ';
      case QuestionType.drag:
        return 'Порядок';
      case QuestionType.connection:
        return 'Соответствие';
    }
  }
}

