part of 'view_question_screen.dart';

class _QuestionTextView extends StatelessWidget {
  final String text;
  final QuestionType type;

  const _QuestionTextView({required this.text, required this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('ТЕКСТ ВОПРОСА', style: AppTextStyles.sectionTag),
        const SizedBox(height: 8),
        Text(
          text,
          style: AppTextStyles.subtitle.copyWith(color: AppColors.mono900),
        ),
        const SizedBox(height: 10),
        _TypeChip(type: type),
        const SizedBox(height: 10),
        Container(height: 1, color: AppColors.mono100),
      ],
    );
  }
}

