part of 'take_quiz_screen.dart';

class _TopBar extends StatelessWidget {
  final TakeQuizInProgress state;
  final VoidCallback onBack;

  const _TopBar({required this.state, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close,
                size: 22, color: AppColors.mono700),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              state.quizTitle,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.mono900,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (state.hasTimer)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: (state.remainingSeconds ?? 0) < 60
                    ? const Color(0xFFFEE2E2)
                    : AppColors.mono50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (state.remainingSeconds ?? 0) < 60
                      ? const Color(0xFFEF4444)
                      : AppColors.mono150,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: (state.remainingSeconds ?? 0) < 60
                        ? const Color(0xFFEF4444)
                        : AppColors.mono400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    state.timerDisplay,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: (state.remainingSeconds ?? 0) < 60
                          ? const Color(0xFFEF4444)
                          : AppColors.mono700,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}

