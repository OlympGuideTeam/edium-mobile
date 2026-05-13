part of 'live_student_screen.dart';

class _GivenAnswerDistribution extends StatelessWidget {
  final LiveQuestionStats? stats;
  const _GivenAnswerDistribution({required this.stats});

  static const _green = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correct = stats?.correctCount ?? 0;
    final incorrect = stats is LiveBinaryStats
        ? (stats as LiveBinaryStats).incorrectCount
        : (total - correct).clamp(0, total).toInt();
    final correctPct = total > 0 ? correct / total : 0.0;
    final incorrectPct = total > 0 ? incorrect / total : 0.0;

    final track = Colors.white.withValues(alpha: 0.08);
    const labelStyle = TextStyle(
      fontSize: 12,
      color: AppColors.liveDarkMuted,
    );
    const countStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      fontFeatures: [FontFeature.tabularFigures()],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.liveDarkCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.liveDarkBorder, width: 1.5),
      ),
      child: Column(
        children: [
          _BinaryBar(
            label: 'Верно',
            count: correct,
            pct: correctPct,
            fillColor: _green,
            trackColor: track,
            labelStyle: labelStyle,
            countStyle: countStyle,
          ),
          const SizedBox(height: 8),
          _BinaryBar(
            label: 'Неверно',
            count: incorrect,
            pct: incorrectPct,
            fillColor: Colors.white.withValues(alpha: 0.22),
            trackColor: track,
            labelStyle: labelStyle,
            countStyle: countStyle,
          ),
        ],
      ),
    );
  }
}

