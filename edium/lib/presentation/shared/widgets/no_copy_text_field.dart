import 'package:flutter/material.dart';

class NoCopyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final int? maxLines;
  final TextStyle? style;
  final Color? cursorColor;
  final InputDecoration? decoration;
  final ValueChanged<String>? onChanged;

  const NoCopyTextField({
    super.key,
    this.controller,
    this.maxLines,
    this.style,
    this.cursorColor,
    this.decoration,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: style,
      cursorColor: cursorColor,
      decoration: decoration,
      onChanged: onChanged,
      enableInteractiveSelection: false,
      contextMenuBuilder: (context, editableTextState) => const SizedBox.shrink(),
    );
  }
}
