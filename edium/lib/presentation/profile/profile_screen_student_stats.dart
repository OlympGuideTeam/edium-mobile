part of 'profile_screen.dart';

class _StudentStats extends StatelessWidget {
  final UserStatistic statistic;

  const _StudentStats({required this.statistic});

  @override
  Widget build(BuildContext context) {
    final score = statistic.avgQuizScore;
    final scoreStr = score == score.roundToDouble()
        ? score.toInt().toString()
        : score.toStringAsFixed(1);

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: statistic.courseStudentCount.toString(),
            label: 'Классов',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: statistic.quizCountPassed.toString(),
            label: 'Квизов',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: scoreStr,
            label: 'Ср. оценка',
          ),
        ),
      ],
    );
  }
}

