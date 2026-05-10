part of 'quiz_library_screen.dart';

class _LiveSessionCard extends StatelessWidget {
  final LiveLibrarySession session;
  final VoidCallback onTap;

  const _LiveSessionCard({required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mono150),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.quizTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.mono900,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _PhaseBadge(phase: session.phase),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (session.joinCode != null) ...[
                  const Icon(Icons.key_rounded,
                      size: 14, color: AppColors.mono400),
                  const SizedBox(width: 4),
                  Text(
                    session.joinCode!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.mono700,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                const Icon(Icons.people_outline_rounded,
                    size: 14, color: AppColors.mono400),
                const SizedBox(width: 4),
                Text(
                  '${session.participantsCount}',
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.mono600),
                ),
                const Spacer(),
                Text(
                  _formatDate(session.createdAt),
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.mono400),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) return 'Сегодня';
    if (diff == 1) return 'Вчера';
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
  }
}

