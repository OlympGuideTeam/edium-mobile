part of 'edit_profile_screen.dart';

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool enabled;

  const _InputField({
    required this.controller,
    required this.hint,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: enabled ? AppColors.mono250 : AppColors.mono150,
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        textCapitalization: TextCapitalization.words,
        cursorColor: AppColors.mono900,
        style: AppTextStyles.fieldText,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.fieldHint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

