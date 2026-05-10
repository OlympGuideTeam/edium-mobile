part of 'quiz_result_screen.dart';

class _StatusDot extends StatelessWidget {
  final _AnswerStatus status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    late final Color bg;
    late final Color fg;
    late final IconData icon;
    switch (status) {
      case _AnswerStatus.correct:
        bg = _ResultBody._greenBg;
        fg = _ResultBody._green;
        icon = Icons.check;
        break;
      case _AnswerStatus.wrong:
        bg = _ResultBody._redBg;
        fg = _ResultBody._red;
        icon = Icons.close;
        break;
      case _AnswerStatus.partial:
        bg = _ResultBody._amberBg;
        fg = _ResultBody._amber;
        icon = Icons.remove;
        break;
      case _AnswerStatus.pending:
        bg = AppColors.mono50;
        fg = AppColors.mono400;
        icon = Icons.hourglass_bottom;
        break;
    }
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, size: 16, color: fg),
    );
  }
}

