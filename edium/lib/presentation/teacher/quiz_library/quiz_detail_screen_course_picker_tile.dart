part of 'quiz_detail_screen.dart';

class _CoursePickerTile extends StatelessWidget {
  final _CourseEntry entry;
  final VoidCallback onTap;

  const _CoursePickerTile({required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.mono25,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.mono100),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.course.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.className,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.mono400),
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

