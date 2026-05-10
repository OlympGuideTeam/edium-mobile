part of 'view_question_screen.dart';

class _ReadOnlyConnectionPairTile extends StatelessWidget {
  final String leftText;
  final String rightText;
  final int index;

  const _ReadOnlyConnectionPairTile({
    required this.leftText,
    required this.rightText,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.mono25,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mono150),
              ),
              child: Text(
                leftText,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mono900),
              ),
            ),
          ),
          Container(
            width: 36,
            color: Colors.white,
            alignment: Alignment.center,
            child: Container(width: 20, height: 1, color: AppColors.mono300),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.mono25,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mono150),
              ),
              child: Text(
                rightText,
                style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.mono900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

