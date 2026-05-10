part of 'view_question_screen.dart';

class _ReadOnlyTextTile extends StatelessWidget {
  final String text;
  final String hint;

  const _ReadOnlyTextTile({required this.text, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Text(
        text.isNotEmpty ? text : hint,
        style: AppTextStyles.bodySmall.copyWith(
          color: text.isNotEmpty ? AppColors.mono900 : AppColors.mono300,
        ),
      ),
    );
  }
}

