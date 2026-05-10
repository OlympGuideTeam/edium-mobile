part of 'create_quiz_screen.dart';

class _QuestionsList extends StatelessWidget {
  final List<Map<String, dynamic>> questions;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(int index) onEdit;
  final VoidCallback onAIGenerate;

  const _QuestionsList({
    required this.questions,
    required this.onAdd,
    required this.onRemove,
    required this.onEdit,
    required this.onAIGenerate,
  });

  static const _typeLabel = {
    'single_choice': 'Один ответ',
    'multiple_choice': 'Несколько ответов',
    'with_given_answer': 'Данный ответ',
    'with_free_answer': 'Свободный ответ',
    'drag': 'Порядок',
    'connection': 'Соответствие',
  };

  static const _typeIcon = {
    'single_choice': Icons.radio_button_checked_outlined,
    'multiple_choice': Icons.check_box_outlined,
    'with_given_answer': Icons.text_fields_outlined,
    'with_free_answer': Icons.edit_outlined,
    'drag': Icons.swap_vert_outlined,
    'connection': Icons.device_hub_outlined,
  };


  static const double _questionsActionRowHeight = 48;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: _questionsActionRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _AddQuestionButton(onTap: onAdd)),
              const SizedBox(width: 10),
              SizedBox(
                width: 76,
                child: _AIGenerateButton(onTap: onAIGenerate),
              ),
            ],
          ),
        ),
        if (questions.isEmpty) ...[
          const SizedBox(height: 12),
          _EmptyQuestionsState(),
        ],
        if (questions.isNotEmpty) ...[
          const SizedBox(height: 12),
          ...List.generate(questions.length, (i) {
            final q = questions[i];
            final type = q['type'] as String? ?? 'single_choice';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SwipeToDeleteTile(
                key: ValueKey('$i-${q['text']}'),
                onDelete: () => onRemove(i),
                child: _QuestionTile(
                  index: i,
                  text: q['text'] as String? ?? '',
                  type: type,
                  typeLabel: _typeLabel[type] ?? type,
                  typeIcon: _typeIcon[type] ?? Icons.help_outline,
                  onTap: () => onEdit(i),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }
}

