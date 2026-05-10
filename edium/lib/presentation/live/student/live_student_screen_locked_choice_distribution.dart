part of 'live_student_screen.dart';

class _LockedChoiceDistribution extends StatelessWidget {
  final LiveQuestion question;
  final LiveChoiceStats? stats;
  final LiveCorrectAnswer correctAnswer;
  final Map<String, dynamic>? myAnswer;

  const _LockedChoiceDistribution({
    required this.question,
    required this.stats,
    required this.correctAnswer,
    this.myAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats?.answeredCount ?? 0;
    final correctIds = _correctIds();
    final selectedIds = _selectedIds();
    final isMulti = question.type == QuestionType.multiChoice;

    return Column(
      children: question.options.map((opt) {
        final dist = stats?.distribution
            .where((d) => d.optionId == opt.id)
            .firstOrNull;
        final pct = total > 0 ? (dist?.count ?? 0) / total : 0.0;
        final isCorrectOpt = correctIds.contains(opt.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _LockedOptionFillCell(
            text: opt.text,
            fillFraction: pct,
            isCorrect: isCorrectOpt,
            isMulti: isMulti,
            isSelected: selectedIds.contains(opt.id),
          ),
        );
      }).toList(),
    );
  }

  Set<String> _selectedIds() {
    if (myAnswer == null) return {};
    final singleId = myAnswer!['selected_option_id'] as String? ??
        myAnswer!['option_id'] as String?;
    if (singleId != null) return {singleId};
    final multiIds = (myAnswer!['selected_option_ids'] as List<dynamic>?) ??
        (myAnswer!['option_ids'] as List<dynamic>?);
    if (multiIds != null) return multiIds.map((e) => e.toString()).toSet();
    return {};
  }

  Set<String> _correctIds() {
    if (correctAnswer.correctOptionIds != null) {
      return correctAnswer.correctOptionIds!.toSet();
    }
    if (correctAnswer.correctOptionId != null) {
      return {correctAnswer.correctOptionId!};
    }
    return {};
  }
}

