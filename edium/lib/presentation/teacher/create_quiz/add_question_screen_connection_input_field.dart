part of 'add_question_screen.dart';

class _ConnectionInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isLeft;
  final int maxChars;
  const _ConnectionInputField({
    required this.controller,
    required this.hint,
    required this.isLeft,
    required this.maxChars,
  });

  @override
  State<_ConnectionInputField> createState() => _ConnectionInputFieldState();
}

class _ConnectionInputFieldState extends State<_ConnectionInputField> {
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
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: focused ? AppColors.mono700 : AppColors.mono150,
          width: focused ? 1.5 : 1.0,
        ),
      ),
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
          hintText: widget.hint,
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
    );
  }
}

