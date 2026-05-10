part of 'live_teacher_screen.dart';

class _BinaryDistribution extends StatelessWidget {
  final LiveBinaryStats? stats;
  const _BinaryDistribution({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correctPct = total > 0 ? (stats!.correctCount / total) : 0.0;
    final incorrectPct = total > 0 ? (stats!.incorrectCount / total) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        children: [
          _BinaryBar(label: 'Верно', count: stats?.correctCount ?? 0, pct: correctPct, color: const Color(0xFF22C55E)),
          const SizedBox(height: 8),
          _BinaryBar(label: 'Неверно', count: stats?.incorrectCount ?? 0, pct: incorrectPct, color: AppColors.mono300),
        ],
      ),
    );
  }
}

