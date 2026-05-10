part of 'live_student_screen.dart';

class _LeaderboardRow extends StatelessWidget {
  final LiveLeaderboardRow row;
  final bool isLast;

  const _LeaderboardRow({required this.row, required this.isLast});

  static const _gold = Color(0xFFFACC15);
  static const _silver = Color(0xFF94A3B8);
  static const _bronze = Color(0xFFFB923C);

  @override
  Widget build(BuildContext context) {
    final isMe = row.isMe;
    final isTop3 = row.position >= 1 && row.position <= 3;
    final medalColors = [_gold, _silver, _bronze];

    return Container(
      margin: EdgeInsets.only(bottom: isLast ? 0 : 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe
            ? AppColors.liveAccent.withValues(alpha: 0.12)
            : AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMe
              ? AppColors.liveAccent.withValues(alpha: 0.5)
              : AppColors.liveDarkBorder,
          width: isMe ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          isTop3
              ? Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: medalColors[row.position - 1],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${row.position}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                )
              : SizedBox(
                  width: 28,
                  child: Text(
                    '${row.position}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.liveDarkMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              row.name.isNotEmpty ? row.name : '—',
              style: TextStyle(
                color: isMe ? Colors.white : Colors.white70,
                fontSize: 15,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isMe) ...[
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.liveAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Я',
                style: TextStyle(
                  color: AppColors.liveAccent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            row.score.toStringAsFixed(row.score % 1 == 0 ? 0 : 1),
            style: TextStyle(
              color: isMe ? AppColors.liveAccent : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}


String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.length >= 2) {
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
  return name.isNotEmpty ? name[0].toUpperCase() : '?';
}

