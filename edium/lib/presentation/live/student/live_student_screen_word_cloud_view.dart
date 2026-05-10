part of 'live_student_screen.dart';

class _WordCloudView extends StatelessWidget {
  final List<String> words;
  final List<String> correctAnswers;

  const _WordCloudView({
    required this.words,
    required this.correctAnswers,
  });

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF22C55E);
    final correctSet =
        correctAnswers.map((a) => a.toLowerCase().trim()).toSet();

    final freq = <String, int>{};
    for (final w in words) {
      freq[w] = (freq[w] ?? 0) + 1;
    }

    final someoneCorrect =
        freq.keys.any((w) => correctSet.contains(w.toLowerCase().trim()));
    final showNote = !someoneCorrect;

    final maxFreq =
        freq.values.fold(1, (a, b) => a > b ? a : b);

    final entries = freq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (entries.isNotEmpty) ...[
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: entries.map((e) {
              final isCorrect =
                  correctSet.contains(e.key.toLowerCase().trim());
              final fontSize = 13.0 + (e.value / maxFreq) * 14.0;
              return Text(
                e.key,
                style: TextStyle(
                  fontSize: fontSize,
                  color: isCorrect ? green : Colors.white70,
                  fontWeight:
                      isCorrect ? FontWeight.w700 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
        ],
        if (showNote && correctAnswers.isNotEmpty)
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: green.withValues(alpha: 0.35)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline,
                    color: green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Правильный ответ: ${correctAnswers.join(', ')}',
                    style: const TextStyle(
                      color: green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        if (entries.isEmpty && correctAnswers.isEmpty)
          const Text(
            'Никто не ответил',
            style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
          ),
      ],
    );
  }
}

