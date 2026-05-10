part of 'live_teacher_screen.dart';

class _LeaderboardTab extends StatelessWidget {
  final List<LiveResultsTeacherAttempt> leaderboard;
  const _LeaderboardTab({required this.leaderboard});

  @override
  Widget build(BuildContext context) {
    if (leaderboard.isEmpty) {
      return const Center(
        child: Text('Нет данных', style: TextStyle(color: AppColors.mono400)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      itemCount: leaderboard.length,
      itemBuilder: (context, i) => _LeaderboardRow(row: leaderboard[i]),
    );
  }
}

