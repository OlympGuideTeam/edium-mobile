part of 'live_teacher_screen.dart';

class _MonitorBottomBar extends StatelessWidget {
  final bool isLast;
  final VoidCallback? onNext;

  const _MonitorBottomBar({
    required this.isLast,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50.withValues(alpha: 0.95),
        border: const Border(top: BorderSide(color: AppColors.mono150)),
      ),
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, math.max(MediaQuery.of(context).padding.bottom, 16)),
      child: EdiumButton(
        label: isLast ? 'Завершить квиз' : 'Следующий →',
        onPressed: onNext,
      ),
    );
  }
}

