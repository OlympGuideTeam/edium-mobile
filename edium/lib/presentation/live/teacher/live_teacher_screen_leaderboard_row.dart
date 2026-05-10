part of 'live_teacher_screen.dart';

class _LeaderboardRow extends StatelessWidget {
  final LiveResultsTeacherAttempt row;
  const _LeaderboardRow({required this.row});

  static const _podiumBg = [
    Color(0xFFFEF9C3),
    Color(0xFFF1F5F9),
    Color(0xFFFFF7ED),
  ];
  static const _podiumBorder = [
    Color(0xFFFACC15),
    Color(0xFFCBD5E1),
    Color(0xFFFDBA74),
  ];
  static const _podiumScore = [
    Color(0xFFCA8A04),
    Color(0xFF64748B),
    Color(0xFFEA580C),
  ];

  bool get _isTop3 => row.position >= 1 && row.position <= 3;
  int get _idx => row.position - 1;

  @override
  Widget build(BuildContext context) {
    final bg = _isTop3 ? _podiumBg[_idx] : Colors.white;
    final border = _isTop3 ? _podiumBorder[_idx] : AppColors.mono150;
    final scoreColor = _isTop3 ? _podiumScore[_idx] : AppColors.mono900;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _PositionMark(position: row.position),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.name.isNotEmpty ? row.name : '—',
                  style: const TextStyle(
                    color: AppColors.mono900,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${row.correctCount} верных ответов',
                  style: const TextStyle(color: AppColors.mono400, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${row.score.toInt()}',
                style: TextStyle(
                  color: scoreColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                'баллов',
                style: TextStyle(color: scoreColor.withValues(alpha: 0.7), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

