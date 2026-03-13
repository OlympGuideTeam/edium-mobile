import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String hint;
  final VoidCallback? onClear;

  const SearchBarWidget({
    super.key,
    required this.onChanged,
    this.hint = 'Поиск...',
    this.onClear,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (v) {
          setState(() {});
          widget.onChanged(v);
        },
        style: AppTextStyles.bodySmall,
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle:
              AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, size: 18,
              color: AppColors.textSecondary),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    widget.onChanged('');
                    widget.onClear?.call();
                    setState(() {});
                  },
                  child: const Icon(Icons.clear, size: 18,
                      color: AppColors.textSecondary),
                )
              : null,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }
}
