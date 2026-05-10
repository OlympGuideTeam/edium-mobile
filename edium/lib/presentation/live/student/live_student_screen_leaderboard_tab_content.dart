part of 'live_student_screen.dart';

class _LeaderboardTabContent extends StatelessWidget {
  final List<LiveLeaderboardRow> top;
  const _LeaderboardTabContent({required this.top});

  @override
  Widget build(BuildContext context) {
    if (top.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных',
          style: TextStyle(color: AppColors.liveDarkMuted, fontSize: 14),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      itemCount: top.length,
      itemBuilder: (_, i) =>
          _LeaderboardRow(row: top[i], isLast: i == top.length - 1),
    );
  }
}

