part of 'live_teacher_screen.dart';

class _PositionMark extends StatelessWidget {
  final int position;
  const _PositionMark({required this.position});

  @override
  Widget build(BuildContext context) {
    if (position > 3) {
      return SizedBox(
        width: 28,
        child: Text(
          '$position',
          style: const TextStyle(
            color: AppColors.mono400,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    const medalColors = [
      Color(0xFFFACC15),
      Color(0xFF94A3B8),
      Color(0xFFFB923C),
    ];
    const medalLabels = ['1', '2', '3'];

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: medalColors[position - 1],
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        medalLabels[position - 1],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

