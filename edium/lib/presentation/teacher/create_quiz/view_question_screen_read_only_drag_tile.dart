part of 'view_question_screen.dart';

class _ReadOnlyDragTile extends StatelessWidget {
  final int index;
  final String text;

  const _ReadOnlyDragTile({required this.index, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.mono25,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mono150),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.mono150)),
              ),
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.mono400,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 13),
                child: Text(
                  text,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.mono900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

