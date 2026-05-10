part of 'review_session_screen.dart';

class _SummaryStrip extends StatelessWidget {
  final int gradedCount;
  final int gradingCount;
  final int completedCount;

  const _SummaryStrip({
    required this.gradedCount,
    required this.gradingCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.mono50,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(
          color: AppColors.mono150,
          width: AppDimens.borderWidth,
        ),
      ),
      child: Row(
        children: [
          _Cell(
            value: '$gradedCount',
            label: 'Ждут учителя',
            highlight: gradedCount > 0,
          ),
          _Divider(),
          _Cell(
            value: '$gradingCount',
            label: 'Проверяет ИИ',
            highlight: false,
          ),
          _Divider(),
          _Cell(
            value: '$completedCount',
            label: 'Проверено',
            highlight: false,
          ),
        ],
      ),
    );
  }
}

