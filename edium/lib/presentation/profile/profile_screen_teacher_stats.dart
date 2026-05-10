part of 'profile_screen.dart';

class _TeacherStats extends StatelessWidget {
  final UserStatistic statistic;

  const _TeacherStats({required this.statistic});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: statistic.classTeacherCount.toString(),
            label: 'Классов',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: statistic.quizSessionsConducted.toString(),
            label: 'Квизы',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            value: statistic.studentCount.toString(),
            label: 'Учеников',
          ),
        ),
      ],
    );
  }
}

