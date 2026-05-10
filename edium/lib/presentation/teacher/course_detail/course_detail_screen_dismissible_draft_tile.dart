part of 'course_detail_screen.dart';

class _DismissibleDraftTile extends StatelessWidget {
  final CourseDraft draft;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _DismissibleDraftTile({
    super.key,
    required this.draft,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      child: Container(
        color: AppColors.error,
        child: Dismissible(
          key: ValueKey(draft.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onDelete(),
          background: Container(
            color: AppColors.error,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white, size: 20),
          ),
          child: _DraftTile(draft: draft, onTap: onTap),
        ),
      ),
    );
  }
}

