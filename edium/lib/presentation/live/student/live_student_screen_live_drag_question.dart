part of 'live_student_screen.dart';

class _LiveDragQuestion extends StatefulWidget {
  final LiveQuestion question;
  final ValueChanged<List<String>> onConfirm;

  const _LiveDragQuestion({required this.question, required this.onConfirm});

  @override
  State<_LiveDragQuestion> createState() => _LiveDragQuestionState();
}

class _LiveDragQuestionState extends State<_LiveDragQuestion> {
  late List<String> _items;

  @override
  void initState() {
    super.initState();
    _items = (widget.question.metadata?['items'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Перетащите элементы в правильном порядке:',
          style: TextStyle(fontSize: 13, color: AppColors.liveDarkMuted),
        ),
        const SizedBox(height: 12),
        Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
          child: ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) => Material(
              elevation: 6,
              color: Colors.transparent,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: child,
            ),
            onReorder: (oldIdx, newIdx) {
              setState(() {
                if (newIdx > oldIdx) newIdx--;
                final item = _items.removeAt(oldIdx);
                _items.insert(newIdx, item);
              });
            },
            children: _items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              return ReorderableDragStartListener(
                key: ValueKey(item),
                index: i,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.liveDarkCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.liveDarkBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.liveDarkMuted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.white),
                        ),
                      ),
                      const Icon(Icons.drag_handle,
                          color: AppColors.liveDarkMuted, size: 20),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        _ConfirmButton(
          enabled: _items.isNotEmpty,
          onTap: () => widget.onConfirm(List.from(_items)),
        ),
      ],
    );
  }
}

