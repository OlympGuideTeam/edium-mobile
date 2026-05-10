part of 'student_question_review_sheet.dart';

class _FreeAnswerBlock extends StatelessWidget {
  final String studentText;
  const _FreeAnswerBlock({required this.studentText});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusSm),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Text(
        studentText.isEmpty ? '— нет ответа —' : studentText,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.mono700,
          height: 1.5,
        ),
      ),
    );
  }
}

