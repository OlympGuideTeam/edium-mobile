part of 'add_question_screen.dart';

class _ConnectionForm extends StatefulWidget {
  final List<_ConnectionPair> pairs;
  final int maxChars;
  final VoidCallback onChanged;

  const _ConnectionForm({
    required this.pairs,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  State<_ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<_ConnectionForm> {
  void _add() {
    setState(() => widget.pairs.add(_ConnectionPair()));
    widget.onChanged();
  }

  void _remove(int i) {
    if (widget.pairs.length <= 2) return;
    setState(() {
      widget.pairs[i].leftCtrl.dispose();
      widget.pairs[i].rightCtrl.dispose();
      widget.pairs.removeAt(i);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.pairs.length > 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ПАРЫ СООТВЕТСТВИЯ', style: AppTextStyles.sectionTag),
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
        Row(
          children: [
            Expanded(
              child: Text('Левая колонка',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.mono400, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 36),
            Expanded(
              child: Text('Правая колонка',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.mono400, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...List.generate(widget.pairs.length, (i) {
          final pair = widget.pairs[i];
          return _entryAnimation(
            key: ValueKey(pair.id),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildDismissible(
                key: ValueKey(pair.id),
                canDismiss: canDelete,
                onDismissed: () => _remove(i),

                child: _ConnectionPairTile(
                  leftController: pair.leftCtrl,
                  rightController: pair.rightCtrl,
                  index: i,
                  maxChars: widget.maxChars,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 4),
        _dashedAddRowButton(label: '+ Добавить пару', onTap: _add),
        const SizedBox(height: 8),
        Text(
          'Студент соединит левые элементы с правыми',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

