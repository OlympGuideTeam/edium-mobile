part of 'add_question_screen.dart';

class _DragItemTile extends StatefulWidget {
  final int index;
  final TextEditingController controller;
  final int maxChars;

  const _DragItemTile({required this.index, required this.controller, required this.maxChars});

  @override
  State<_DragItemTile> createState() => _DragItemTileState();
}

class _DragItemTileState extends State<_DragItemTile> {
  late final FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = FocusNode()..addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.mono700 : AppColors.mono150,
          width: focused ? 1.5 : 1.0,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ReorderableDragStartListener(
              index: widget.index,
              child: Container(
                width: 44,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.mono150)),
                ),
                child: const Icon(Icons.drag_indicator, size: 18, color: AppColors.mono300),
              ),
            ),
            Expanded(
              child: TextField(
                focusNode: _focus,
                controller: widget.controller,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.mono900),
                maxLength: widget.maxChars,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                minLines: 1,
                maxLines: null,
                cursorColor: AppColors.mono900,
                decoration: InputDecoration(
                  hintText: 'Элемент ${widget.index + 1}',
                  hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mono300),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  counterText: '',
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

