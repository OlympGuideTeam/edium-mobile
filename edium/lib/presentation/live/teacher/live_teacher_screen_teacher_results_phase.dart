part of 'live_teacher_screen.dart';

class _TeacherResultsPhase extends StatelessWidget {
  final LiveTeacherResultsLoaded state;
  const _TeacherResultsPhase({required this.state});

  @override
  Widget build(BuildContext context) {
    final results = state.results;

    return Scaffold(
      backgroundColor: AppColors.mono50,
      appBar: AppBar(
        backgroundColor: AppColors.mono50,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.mono900),
          onPressed: () => context.pop(),
        ),
        title: Text('Результаты квиза', style: AppTextStyles.heading3),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              labelColor: AppColors.mono900,
              unselectedLabelColor: AppColors.mono400,
              indicatorColor: AppColors.mono900,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStatePropertyAll(Colors.transparent),
              tabs: [
                Tab(text: 'Лидерборд'),
                Tab(text: 'По вопросам'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _LeaderboardTab(leaderboard: results.leaderboard),
                  _QuestionsTab(questions: results.questions),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

