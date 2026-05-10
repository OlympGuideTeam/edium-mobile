part of 'student_question_review_sheet.dart';

class _Handle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 4),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.mono200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

