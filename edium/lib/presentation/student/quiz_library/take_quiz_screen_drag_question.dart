part of 'take_quiz_screen.dart';

class _DragQuestion extends StatefulWidget {
  final QuizQuestionForStudent question;
  final List<String> currentOrder;
  final ValueChanged<List<String>> onReorder;

  const _DragQuestion({
    required this.question,
    required this.currentOrder,
    required this.onReorder,
  });

  @override
  State<_DragQuestion> createState() => _DragQuestionState();
}

class _DragQuestionState extends State<_DragQuestion> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.currentOrder);
  }

  @override
  void didUpdateWidget(_DragQuestion old) {
    super.didUpdateWidget(old);
    if (old.question.id != widget.question.id) {
      _items = List.from(widget.currentOrder);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Перетащите элементы в правильном порядке:',
          style: TextStyle(fontSize: 13, color: AppColors.mono400),
        ),
        const SizedBox(height: 12),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              return Material(
                elevation: 6,
                color: Colors.transparent,
                shadowColor: Colors.black12,
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex--;
                final item = _items.removeAt(oldIndex);
                _items.insert(newIndex, item);
              });
              widget.onReorder(List.from(_items));
            },
            children: _items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              return ReorderableDragStartListener(
                key: ValueKey('$i:$item'),
                index: i,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mono150, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mono350,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontSize: 15, color: AppColors.mono900),
                        ),
                      ),
                      const Icon(Icons.drag_handle,
                          color: AppColors.mono250, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

