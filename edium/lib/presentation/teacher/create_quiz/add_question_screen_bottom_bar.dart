part of 'add_question_screen.dart';

class _BottomBar extends StatelessWidget {
  final VoidCallback onSave;
  const _BottomBar({required this.onSave});

  @override
  Widget build(BuildContext context) {
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
      child: EdiumButton(label: 'Сохранить вопрос', onPressed: onSave),
    );
  }
}

