part of 'take_quiz_screen.dart';

class _QuestionStrip extends StatelessWidget {
  final TakeQuizInProgress state;
  const _QuestionStrip({required this.state});

  @override
  Widget build(BuildContext context) {
    final total = state.attempt.questions.length;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: total,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isCurrent = i == state.currentIndex;
          final q = state.attempt.questions[i];
          final isAnswered = state.answers[q.id] != null;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => context
                .read<TakeQuizBloc>()
                .add(JumpToQuestionEvent(i)),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppColors.mono900
                    : isAnswered
                        ? AppColors.mono100
                        : Colors.transparent,
                shape: BoxShape.circle,
                border: isCurrent
                    ? null
                    : Border.all(
                        color: isAnswered
                            ? AppColors.mono150
                            : AppColors.mono200,
                        width: 1.5,
                      ),
              ),
              alignment: Alignment.center,
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isCurrent
                      ? Colors.white
                      : isAnswered
                          ? AppColors.mono700
                          : AppColors.mono400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

