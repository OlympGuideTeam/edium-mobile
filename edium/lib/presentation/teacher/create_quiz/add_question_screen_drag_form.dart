part of 'add_question_screen.dart';

class _DragForm extends StatefulWidget {
  final List<TextEditingController> items;
  final int maxChars;
  final VoidCallback onChanged;

  const _DragForm({
    required this.items,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  State<_DragForm> createState() => _DragFormState();
}

class _DragFormState extends State<_DragForm> {
  void _add() {
    setState(() => widget.items.add(TextEditingController()));
    widget.onChanged();
  }

  void _remove(int i) {
    if (widget.items.length <= 2) return;
    setState(() {
      widget.items[i].dispose();
      widget.items.removeAt(i);
    });
    widget.onChanged();
  }

  void _reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    setState(() {
      final ctrl = widget.items.removeAt(oldIndex);
      widget.items.insert(newIndex, ctrl);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final canDelete = widget.items.length > 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ЭЛЕМЕНТЫ В ПРАВИЛЬНОМ ПОРЯДКЕ', style: AppTextStyles.sectionTag),
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
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, _, animation) => Material(
              elevation: 4,
              color: Colors.transparent,
              shadowColor: Colors.black12,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
            onReorder: _reorder,
            children: List.generate(widget.items.length, (i) {
              final ctrl = widget.items[i];
              return _entryAnimation(
                key: ObjectKey(ctrl),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildDismissible(
                    key: ValueKey(ctrl),
                    canDismiss: canDelete,
                    onDismissed: () => _remove(i),
                    child: _DragItemTile(index: i, controller: ctrl, maxChars: widget.maxChars),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 4),
        _dashedAddRowButton(label: '+ Добавить элемент', onTap: _add),
        const SizedBox(height: 8),
        Text(
          'Студент расставит элементы в нужном порядке перетаскиванием',
          style: AppTextStyles.helperText,
        ),
      ],
    );
  }
}

