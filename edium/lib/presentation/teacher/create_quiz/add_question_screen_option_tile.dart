part of 'add_question_screen.dart';

class _OptionTile extends StatefulWidget {
  final TextEditingController controller;
  final bool isCorrect;
  final bool isMulti;
  final VoidCallback onToggle;
  final int maxChars;

  const _OptionTile({
    required this.controller,
    required this.isCorrect,
    required this.isMulti,
    required this.onToggle,
    required this.maxChars,
  });

  @override
  State<_OptionTile> createState() => _OptionTileState();
}

class _OptionTileState extends State<_OptionTile> {
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
          color: widget.isCorrect
              ? AppColors.mono900
              : focused
                  ? AppColors.mono700
                  : AppColors.mono150,
          width: widget.isCorrect || focused ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: widget.onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              child: widget.isMulti
                  ? _CheckboxIcon(isCorrect: widget.isCorrect)
                  : _RadioIcon(isCorrect: widget.isCorrect),
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
                hintText: 'Вариант ответа...',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.mono300),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                counterText: '',
                filled: false,
                contentPadding: const EdgeInsets.only(right: 14, top: 14, bottom: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

