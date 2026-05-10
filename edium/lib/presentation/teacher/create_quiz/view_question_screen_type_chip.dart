part of 'view_question_screen.dart';

class _TypeChip extends StatelessWidget {
  final QuestionType type;
  const _TypeChip({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.mono100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconFor(type), size: 13, color: AppColors.mono400),
          const SizedBox(width: 5),
          Text(
            _labelFor(type),
            style: AppTextStyles.caption.copyWith(
              color: AppColors.mono600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(QuestionType t) => switch (t) {
        QuestionType.singleChoice => Icons.radio_button_checked_outlined,
        QuestionType.multiChoice => Icons.check_box_outlined,
        QuestionType.withGivenAnswer => Icons.text_fields_outlined,
        QuestionType.withFreeAnswer => Icons.edit_outlined,
        QuestionType.drag => Icons.swap_vert_outlined,
        QuestionType.connection => Icons.device_hub_outlined,
      };

  String _labelFor(QuestionType t) => switch (t) {
        QuestionType.singleChoice => 'Один ответ',
        QuestionType.multiChoice => 'Несколько ответов',
        QuestionType.withGivenAnswer => 'Данный ответ',
        QuestionType.withFreeAnswer => 'Свободный ответ',
        QuestionType.drag => 'Порядок',
        QuestionType.connection => 'Соответствие',
      };
}

