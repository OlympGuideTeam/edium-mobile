part of 'add_question_screen.dart';

class _GivenAnswerForm extends StatefulWidget {
  final List<TextEditingController> answers;
  final int maxChars;
  final VoidCallback onChanged;

  const _GivenAnswerForm({
    required this.answers,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  State<_GivenAnswerForm> createState() => _GivenAnswerFormState();
}

class _GivenAnswerFormState extends State<_GivenAnswerForm> {
  void _add() {
    setState(() => widget.answers.add(TextEditingController()));
    widget.onChanged();
  }

  void _remove(int i) {
    if (widget.answers.length <= 1) return;
    setState(() {
      widget.answers[i].dispose();
      widget.answers.removeAt(i);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ПРАВИЛЬНЫЕ ОТВЕТЫ', style: AppTextStyles.sectionTag),
            GestureDetector(
              onTap: _add,
              child: Row(
                children: [
                  const Icon(Icons.add, size: 14, color: AppColors.mono700),
                  const SizedBox(width: 2),
                  Text('Добавить',
                      style: AppTextStyles.caption.copyWith(
                          color: AppColors.mono700, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...List.generate(widget.answers.length, (i) {
          final ctrl = widget.answers[i];
          return _entryAnimation(
            key: ValueKey(ctrl),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDismissible(
                key: ValueKey(ctrl),
                canDismiss: widget.answers.length > 1,
                onDismissed: () => _remove(i),
                child: _TextInputTile(
                  controller: ctrl,
                  hint: 'Принимаемый ответ ${i + 1}',
                  maxChars: widget.maxChars,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _dashedAddRowButton(label: '+ Добавить ответ', onTap: _add),
        const SizedBox(height: 8),
        Text(
          'Система примет любой из указанных вариантов написания',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

