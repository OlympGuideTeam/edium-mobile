part of 'course_detail_screen.dart';

class _DraftsSectionHeader extends StatelessWidget {
  const _DraftsSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _DashedDivider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'Черновики',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.mono400,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(child: _DashedDivider()),
      ],
    );
  }
}

