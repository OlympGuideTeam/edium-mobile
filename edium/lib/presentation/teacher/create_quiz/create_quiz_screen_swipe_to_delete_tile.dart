part of 'create_quiz_screen.dart';

class _SwipeToDeleteTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onDelete;

  const _SwipeToDeleteTile({
    super.key,
    required this.child,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        color: AppColors.error,
        child: Dismissible(
          key: key!,
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(),
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.delete_outline,
                color: Colors.white, size: 20),
          ),
          child: child,
        ),
      ),
    );
  }
}

