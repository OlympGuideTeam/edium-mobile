part of 'live_teacher_screen.dart';

class _AllPendingAnsweredPlaceholder extends StatelessWidget {
  const _AllPendingAnsweredPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 50),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.mono400),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Все ответили',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.mono600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

