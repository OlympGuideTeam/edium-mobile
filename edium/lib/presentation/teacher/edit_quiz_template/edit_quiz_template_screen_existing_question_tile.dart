part of 'edit_quiz_template_screen.dart';

class _ExistingQuestionTile extends StatelessWidget {
  final int index;
  final Question question;
  final String? overrideText;
  final String? overrideType;
  final bool isModified;
  final VoidCallback onTap;

  const _ExistingQuestionTile({
    required this.index,
    required this.question,
    required this.onTap,
    this.overrideText,
    this.overrideType,
    this.isModified = false,
  });

  static const _typeLabel = {
    QuestionType.singleChoice: 'Один ответ',
    QuestionType.multiChoice: 'Несколько ответов',
    QuestionType.withFreeAnswer: 'Свободный ответ',
    QuestionType.withGivenAnswer: 'Данный ответ',
    QuestionType.drag: 'Порядок',
    QuestionType.connection: 'Соответствие',
  };

  static const _typeLabelStr = {
    'single_choice': 'Один ответ',
    'multiple_choice': 'Несколько ответов',
    'with_free_answer': 'Свободный ответ',
    'with_given_answer': 'Данный ответ',
    'drag': 'Порядок',
    'connection': 'Соответствие',
  };

  static const _typeIcon = {
    QuestionType.singleChoice: Icons.radio_button_checked_outlined,
    QuestionType.multiChoice: Icons.check_box_outlined,
    QuestionType.withFreeAnswer: Icons.edit_outlined,
    QuestionType.withGivenAnswer: Icons.text_fields_outlined,
    QuestionType.drag: Icons.swap_vert_outlined,
    QuestionType.connection: Icons.device_hub_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final displayText = overrideText ?? question.text;
    final displayTypeLabel = overrideType != null
        ? (_typeLabelStr[overrideType] ?? 'Вопрос')
        : (_typeLabel[question.type] ?? 'Вопрос');
    final displayTypeIcon = overrideType == null
        ? (_typeIcon[question.type] ?? Icons.help_outline)
        : Icons.help_outline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isModified ? AppColors.mono300 : AppColors.mono100,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mono900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayText.isEmpty ? 'Без текста' : displayText,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(displayTypeIcon, size: 12, color: AppColors.mono400),
                      const SizedBox(width: 4),
                      Text(displayTypeLabel, style: AppTextStyles.caption),
                      if (isModified) ...[
                        const SizedBox(width: 6),
                        Text(
                          '• изменён',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.mono400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.mono300),
          ],
        ),
      ),
    );
  }
}

