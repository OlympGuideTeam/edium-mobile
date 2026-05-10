part of 'student_quiz_library_screen.dart';

class _EmptyPlaceholder extends StatelessWidget {
  final bool isEmpty;
  final String emptyText;
  const _EmptyPlaceholder({required this.isEmpty, required this.emptyText});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.quiz_outlined, size: 48, color: AppColors.mono200),
        const SizedBox(height: 12),
        Text(
          isEmpty ? emptyText : 'Ничего не найдено',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.mono900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isEmpty ? '' : 'Попробуйте изменить поисковый запрос',
          style: AppTextStyles.screenSubtitle,
        ),
      ],
    );
  }
}

