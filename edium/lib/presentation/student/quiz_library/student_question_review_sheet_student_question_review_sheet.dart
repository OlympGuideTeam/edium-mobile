part of 'student_question_review_sheet.dart';

class _StudentQuestionReviewSheet extends StatelessWidget {
  final StudentQuestionReviewData data;
  const _StudentQuestionReviewSheet({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.92;
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(),
          _SheetTopBar(
            index: data.index,
            total: data.total,
            onClose: () => Navigator.pop(context),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.screenPaddingH, 0, AppDimens.screenPaddingH, 32),
              child: _QuestionReviewBody(data: data),
            ),
          ),
        ],
      ),
    );
  }
}

