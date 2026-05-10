part of 'live_teacher_screen.dart';

class _QuestionsTab extends StatelessWidget {
  final List<LiveResultsTeacherQuestion> questions;
  const _QuestionsTab({required this.questions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: questions.length,
      itemBuilder: (context, i) {
        final q = questions[i];
        final pct = (q.correctRate * 100).round();
        final answered = q.stats.answeredCount;
        final correct = q.stats.correctCount;
        final barColor = pct >= 60 ? const Color(0xFF22C55E) : AppColors.liveAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.mono150),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration:
                    const BoxDecoration(color: AppColors.mono100, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  '${q.orderIndex}',
                  style: const TextStyle(
                      color: AppColors.mono600, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      q.text,
                      style: const TextStyle(
                          color: AppColors.mono900,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: q.correctRate.clamp(0.0, 1.0),
                        minHeight: 6,
                        backgroundColor: AppColors.mono100,
                        color: barColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '$correct / $answered верных',
                          style: TextStyle(
                            color: barColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '($pct%)',
                          style: const TextStyle(color: AppColors.mono400, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

