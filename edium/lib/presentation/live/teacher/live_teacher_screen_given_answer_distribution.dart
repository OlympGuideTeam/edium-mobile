part of 'live_teacher_screen.dart';

class _GivenAnswerDistribution extends StatelessWidget {
  final LiveBinaryStats? stats;
  const _GivenAnswerDistribution({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correct = stats?.correctCount ?? 0;
    final incorrect = stats?.incorrectCount ?? 0;
    final correctPct = total > 0 ? correct / total : 0.0;
    final incorrectPct = total > 0 ? incorrect / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.mono150),
      ),
      child: Column(
        children: [
          _BinaryBar(label: 'Верно', count: correct, pct: correctPct, color: const Color(0xFF22C55E)),
          const SizedBox(height: 8),
          _BinaryBar(label: 'Неверно', count: incorrect, pct: incorrectPct, color: AppColors.mono300),
        ],
      ),
    );
  }
}

