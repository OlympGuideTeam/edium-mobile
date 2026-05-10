part of 'create_quiz_screen.dart';

class _QuestionTile extends StatelessWidget {
  final int index;
  final String text;
  final String type;
  final String typeLabel;
  final IconData typeIcon;
  final VoidCallback onTap;

  const _QuestionTile({
    required this.index,
    required this.text,
    required this.type,
    required this.typeLabel,
    required this.typeIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.mono900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text.isEmpty ? 'Без текста' : text,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.mono900),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(typeIcon,
                          size: 12, color: AppColors.mono400),
                      const SizedBox(width: 4),
                      Text(typeLabel, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.mono300),
          ],
        ),
      ),
    );
  }
}

