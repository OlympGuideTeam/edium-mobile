part of 'quiz_result_screen.dart';

class _BigScore extends StatelessWidget {
  final double score;
  final double max;
  final int pct;
  const _BigScore({
    required this.score,
    required this.max,
    required this.pct,
  });

  String _fmt(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          _fmt(score),
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w800,
            color: AppColors.mono900,
            height: 1.0,
            letterSpacing: -2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text(
            '/${_fmt(max)}',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: AppColors.mono250,
              height: 1.0,
              letterSpacing: -1.5,
            ),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            '$pct%',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.mono700,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ],
    );
  }
}

