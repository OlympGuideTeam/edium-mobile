part of 'live_teacher_screen.dart';

class _ChoiceDistribution extends StatelessWidget {
  final LiveChoiceStats? stats;
  final List<LiveAnswerOption> options;
  final bool showCorrect;
  final LiveCorrectAnswer? correctAnswer;
  final bool isMulti;

  const _ChoiceDistribution({
    required this.stats,
    required this.options,
    required this.showCorrect,
    required this.correctAnswer,
    required this.isMulti,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correctIds = _correctIds();

    return Column(
      children: options.asMap().entries.map((entry) {
        final opt = entry.value;

        final dist = stats?.distribution.where((d) => d.optionId == opt.id).firstOrNull;
        final count = dist?.count ?? 0;
        final pct = total > 0 ? count / total : 0.0;

        final isCorrectOpt = showCorrect &&
            (correctIds.contains(opt.id) || opt.isCorrect == true);

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _OptionFillCell(
            text: opt.text,
            fillFraction: pct,
            count: count,
            isCorrect: isCorrectOpt,
            isMulti: isMulti,
            showCount: total > 0,
          ),
        );
      }).toList(),
    );
  }

  List<String> _correctIds() {
    if (correctAnswer == null) return [];
    if (correctAnswer!.correctOptionIds != null) return correctAnswer!.correctOptionIds!;
    if (correctAnswer!.correctOptionId != null) return [correctAnswer!.correctOptionId!];
    return [];
  }
}

