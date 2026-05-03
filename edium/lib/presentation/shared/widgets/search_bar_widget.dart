import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hint;
  final VoidCallback? onClear;
  final TextEditingController? controller;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.hint = 'Поиск...',
    this.onClear,
    this.controller,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _internal;
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  bool get _ownsController => widget.controller == null;

  TextEditingController get _controller => widget.controller ?? _internal;

  @override
  void initState() {
    super.initState();
    if (_ownsController) _internal = TextEditingController();
    _controller.addListener(_onTextChanged);
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _internal.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  void _onFocusChange() {
    if (mounted) setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _clear() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: 44,
      decoration: BoxDecoration(
        color: _hasFocus ? AppColors.mono100 : AppColors.mono25,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        cursorColor: AppColors.mono900,
        style: const TextStyle(fontSize: 14, color: AppColors.mono700),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.mono300),
          prefixIcon: Icon(
            Icons.search,
            size: 18,
            color: _hasFocus ? AppColors.mono600 : AppColors.mono350,
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 18,
          ),
          suffixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: hasText
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _clear,
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: AppColors.mono350),
                  )
                : const SizedBox.shrink(key: ValueKey('empty')),
          ),
          suffixIconConstraints: const BoxConstraints(
            minWidth: 36,
            minHeight: 16,
          ),
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}
