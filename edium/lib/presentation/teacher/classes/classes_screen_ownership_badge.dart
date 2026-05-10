part of 'classes_screen.dart';

class _OwnershipBadge extends StatelessWidget {
  final bool isOwner;

  const _OwnershipBadge({required this.isOwner});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOwner ? AppColors.mono900 : AppColors.mono100,
        borderRadius: BorderRadius.circular(AppDimens.radiusXs),
      ),
      child: Text(
        isOwner ? 'ВЛАДЕЛЕЦ' : 'УЧИТЕЛЬ',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: isOwner ? Colors.white : AppColors.mono400,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}


Widget _buildDismissible({
  required Key key,
  required Widget child,
  required VoidCallback onDismissed,
  Future<bool?> Function(DismissDirection direction)? confirmDismiss,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(AppDimens.radiusLg),
    child: Container(
      color: AppColors.error,
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        confirmDismiss: confirmDismiss,
        onDismissed: (_) => onDismissed(),
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 18,
          ),
        ),
        child: child,
      ),
    ),
  );
}

