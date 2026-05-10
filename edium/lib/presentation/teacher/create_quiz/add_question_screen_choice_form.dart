part of 'add_question_screen.dart';

class _ChoiceForm extends StatefulWidget {
  final List<_OptionDraft> options;
  final bool isMulti;
  final int maxChars;
  final VoidCallback onChanged;

  const _ChoiceForm({
    required this.options,
    required this.isMulti,
    required this.onChanged,
    required this.maxChars,
  });

  @override
  State<_ChoiceForm> createState() => _ChoiceFormState();
}

class _ChoiceFormState extends State<_ChoiceForm> {
  void _toggleCorrect(int i) {
    setState(() {
      if (!widget.isMulti) {
        for (var j = 0; j < widget.options.length; j++) {
          widget.options[j].isCorrect = j == i;
        }
      } else {
        widget.options[i].isCorrect = !widget.options[i].isCorrect;
      }
    });
    widget.onChanged();
  }

  void _addOption() {
    if (widget.options.length >= 6) return;
    setState(() => widget.options.add(_OptionDraft()));
    widget.onChanged();
  }

  void _removeOption(int i) {
    if (widget.options.length <= 2) return;
    setState(() {
      widget.options[i].ctrl.dispose();
      widget.options.removeAt(i);
    });
    widget.onChanged();
  }

  Widget _buildAddOptionButton() {
    final canAdd = widget.options.length < 6;
    return _dashedAddRowButton(
      label: '+ Добавить вариант',
      onTap: canAdd ? _addOption : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ВАРИАНТЫ ОТВЕТА', style: AppTextStyles.sectionTag),
            GestureDetector(
              onTap: widget.options.length < 6 ? _addOption : null,
              child: Row(
                children: [
                  Icon(Icons.add,
                      size: 14,
                      color: widget.options.length < 6
                          ? AppColors.mono700
                          : AppColors.mono300),
                  const SizedBox(width: 2),
                  Text(
                    'Добавить',
                    style: AppTextStyles.caption.copyWith(
                      color: widget.options.length < 6
                          ? AppColors.mono700
                          : AppColors.mono300,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
          ...List.generate(widget.options.length, (i) {
            final opt = widget.options[i];
            return _entryAnimation(
              key: ValueKey(opt.id),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildDismissible(
                  key: ValueKey(opt.id),
                  canDismiss: widget.options.length > 2,
                  onDismissed: () => _removeOption(i),
                  child: _OptionTile(
                    controller: opt.ctrl,
                    isCorrect: opt.isCorrect,
                    isMulti: widget.isMulti,
                    onToggle: () => _toggleCorrect(i),
                    maxChars: widget.maxChars,
                  ),
                ),
              ),
            );
          }),
        const SizedBox(height: 4),
        _buildAddOptionButton(),
        const SizedBox(height: 8),
        Text(
          widget.isMulti
              ? 'Отметьте один или несколько правильных ответов'
              : 'Отметьте один правильный ответ',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

