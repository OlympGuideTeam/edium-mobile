part of 'live_student_screen.dart';

class _ResultPositionCircle extends StatelessWidget {
  final int position;
  const _ResultPositionCircle({required this.position});

  static const _gold = Color(0xFFFACC15);
  static const _silver = Color(0xFF94A3B8);
  static const _bronze = Color(0xFFFB923C);

  @override
  Widget build(BuildContext context) {
    final isTop3 = position >= 1 && position <= 3;
    final medalColor = [_gold, _silver, _bronze];

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isTop3
            ? medalColor[position - 1]
            : AppColors.liveDarkSurface,
        border: isTop3
            ? null
            : Border.all(color: AppColors.liveDarkBorder, width: 1.5),
      ),
      alignment: Alignment.center,
      child: Text(
        '$position',
        style: TextStyle(
          color: isTop3 ? Colors.white : Colors.white70,
          fontSize: isTop3 ? 20 : 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

