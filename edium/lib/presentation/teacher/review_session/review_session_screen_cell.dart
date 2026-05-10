part of 'review_session_screen.dart';

class _Cell extends StatelessWidget {
  final String value;
  final String label;
  final bool highlight;

  const _Cell({
    required this.value,
    required this.label,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: highlight ? AppColors.mono900 : AppColors.mono300,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(color: AppColors.mono400),
            ),
          ],
        ),
      ),
    );
  }
}

