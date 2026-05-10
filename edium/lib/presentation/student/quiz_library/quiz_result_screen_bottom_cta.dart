part of 'quiz_result_screen.dart';

class _BottomCta extends StatelessWidget {
  final VoidCallback onPressed;
  const _BottomCta({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimens.screenPaddingH,
        8,
        AppDimens.screenPaddingH,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      child: EdiumButton(
        label: 'К курсу',
        onPressed: onPressed,
      ),
    );
  }
}

