import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hint;
  final VoidCallback? onClear;

  /// Опциональный внешний контроллер. Если не передан — создаётся внутренний.
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
  bool get _ownsController => widget.controller == null;

  TextEditingController get _controller =>
      widget.controller ?? _internal;

  @override
  void initState() {
    super.initState();
    if (_ownsController) _internal = TextEditingController();
    _controller.addListener(_onControllerTick);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerTick);
    if (_ownsController) _internal.dispose();
    super.dispose();
  }

  void _onControllerTick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: AppColors.mono100,
          width: AppDimens.borderWidth,
        ),
      ),
      child: TextField(
        controller: _controller,
        cursorColor: AppColors.mono900,
        style: const TextStyle(fontSize: 14, color: AppColors.mono700),
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle:
              const TextStyle(fontSize: 14, color: AppColors.mono250),
          prefixIcon:
              const Icon(Icons.search, size: 18, color: AppColors.mono250),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _controller.clear();
                    widget.onChanged('');
                    widget.onClear?.call();
                  },
                  child: const Icon(Icons.clear,
                      size: 16, color: AppColors.mono250),
                )
              : null,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}
