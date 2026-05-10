part of 'create_quiz_screen.dart';

class _BottomBar extends StatelessWidget {
  final CreateQuizState state;
  final Future<void> Function() onSave;
  final Future<void> Function() onStart;

  const _BottomBar({
    required this.state,
    required this.onSave,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final canSave = state.canSave && !state.isSubmitting;
    final canPublish = state.canPublish && !state.isSubmitting;

    String? hint;
    if (!state.canSave) {
      hint = 'Введите название';
    } else if (state.isInCourseContext && !state.canPublish) {
      hint = 'Добавьте вопросы, чтобы начать';
    }

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.mono100)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hint != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                hint,
                style: AppTextStyles.helperText,
                textAlign: TextAlign.center,
              ),
            ),
          if (state.isInCourseContext)
            _CourseContextButtons(
              canSave: canSave,
              canPublish: canPublish,
              isSubmitting: state.isSubmitting,
              onSave: onSave,
              onStart: onStart,
            )
          else
            _LibraryButton(
              canSubmit: canSave,
              isSubmitting: state.isSubmitting,
              onPressed: onSave,
            ),
        ],
      ),
    );
  }
}

