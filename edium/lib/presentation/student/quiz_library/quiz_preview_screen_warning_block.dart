part of 'quiz_preview_screen.dart';

class _WarningBlock extends StatelessWidget {
  final String text;
  final bool isError;

  const _WarningBlock({required this.text, this.isError = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isError
            ? const Color(0xFFFEE2E2)
            : AppColors.mono50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError
              ? const Color(0xFFEF4444)
              : AppColors.mono150,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isError
                ? Icons.error_outline
                : Icons.info_outline,
            size: 16,
            color: isError
                ? const Color(0xFFEF4444)
                : AppColors.mono400,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                height: 1.5,
                color: isError
                    ? const Color(0xFFEF4444)
                    : AppColors.mono400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

