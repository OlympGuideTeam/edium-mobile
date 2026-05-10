part of 'live_student_screen.dart';

class _QuestionHeader extends StatelessWidget {
  final int index;
  final DateTime deadlineAt;
  final int timeLimitSec;

  const _QuestionHeader({
    required this.index,
    required this.deadlineAt,
    required this.timeLimitSec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.liveDarkSurface,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Вопрос $index',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              _TimerBadge(
                deadlineAt: deadlineAt,
                timeLimitSec: timeLimitSec,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _TimerProgressBar(
            deadlineAt: deadlineAt,
            timeLimitSec: timeLimitSec,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

