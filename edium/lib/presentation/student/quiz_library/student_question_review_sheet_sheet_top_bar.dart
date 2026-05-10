part of 'student_question_review_sheet.dart';

class _SheetTopBar extends StatelessWidget {
  final int index;
  final int total;
  final VoidCallback onClose;

  const _SheetTopBar({
    required this.index,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimens.screenPaddingH, 8, 8, 12),
      child: Row(
        children: [
          Text(
            'Вопрос $index из $total',
            style: AppTextStyles.screenTitle,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, size: 22, color: AppColors.mono400),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

