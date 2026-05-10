part of 'quiz_library_screen.dart';

class _PhaseBadge extends StatelessWidget {
  final LivePhase phase;

  const _PhaseBadge({required this.phase});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (phase) {
      LivePhase.pending => ('Не начат', AppColors.mono100, AppColors.mono600),
      LivePhase.lobby => (
          'Лобби',
          const Color(0xFFFFF3CD),
          const Color(0xFF92610A)
        ),
      LivePhase.questionActive || LivePhase.questionLocked => (
          'Идёт',
          const Color(0xFFDCFCE7),
          const Color(0xFF166534)
        ),
      LivePhase.completed =>
        ('Завершён', AppColors.mono100, AppColors.mono400),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}


Widget _buildDismissible({
  required Key key,
  required VoidCallback onDismissed,
  required Widget child,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: Container(
      color: AppColors.error,
      child: Dismissible(
        key: key,
        direction: DismissDirection.endToStart,
        onDismissed: (_) => onDismissed(),
        background: Container(
          color: AppColors.error,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_outline,
              color: Colors.white, size: 20),
        ),
        child: child,
      ),
    ),
  );
}

