part of 'live_teacher_screen.dart';

class _LiveStatsRow extends StatelessWidget {
  final int answeredCount;
  final int totalCount;
  final LiveQuestionStats? stats;

  const _LiveStatsRow({
    required this.answeredCount,
    required this.totalCount,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final correctPct = stats != null && stats!.answeredCount > 0
        ? (stats!.correctCount / stats!.answeredCount * 100).round()
        : null;
    final avgTimeSec = stats?.avgTimeMs != null ? (stats!.avgTimeMs! / 1000).round() : null;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _StatsCell(
              label: 'Ответили',
              value: '$answeredCount',
              sub: '/ $totalCount',
              progress: totalCount > 0 ? answeredCount / totalCount : 0.0,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatsCell(
              label: 'Верно',
              value: correctPct != null ? '$correctPct%' : '—',
              valueColor: correctPct != null ? const Color(0xFF22C55E) : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _StatsCell(
              label: 'Ср. время',
              value: avgTimeSec != null ? '$avgTimeSec с' : '—',
            ),
          ),
        ],
      ),
    );
  }
}

