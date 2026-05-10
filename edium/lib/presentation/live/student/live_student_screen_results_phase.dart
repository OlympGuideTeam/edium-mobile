part of 'live_student_screen.dart';

class _ResultsPhase extends StatelessWidget {
  final LiveStudentResultsLoaded state;
  final String attemptId;
  const _ResultsPhase({required this.state, required this.attemptId});

  static const _green = Color(0xFF22C55E);

  String _fmt(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final r = state.results;
    final pct = r.maxScore > 0 ? (r.myScore / r.maxScore * 100).round() : 0;
    final progress =
        r.maxScore > 0 ? (r.myScore / r.maxScore).clamp(0.0, 1.0) : 0.0;
    final wrongCount = r.questionsCount - r.correctCount;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _ResultPositionCircle(position: r.myPosition),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Квиз завершён',
                                style: TextStyle(
                                  color: AppColors.liveDarkMuted,
                                  fontSize: 12,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${r.myPosition} место из ${r.totalParticipants}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _fmt(r.myScore),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                    letterSpacing: -1.5,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  child: Text(
                                    '/${_fmt(r.maxScore)}',
                                    style: const TextStyle(
                                      color: AppColors.liveDarkMuted,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '$pct%',
                              style: const TextStyle(
                                color: AppColors.liveDarkMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6,
                        color: AppColors.liveDarkCard,
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(color: AppColors.liveAccent),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _DarkStatCard(
                            label: 'ПРАВИЛЬНО',
                            value: '${r.correctCount}',
                            valueColor: _green,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DarkStatCard(
                            label: 'НЕВЕРНО',
                            value: '$wrongCount',
                            valueColor: Colors.redAccent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DarkStatCard(
                            label: 'ВОПРОСОВ',
                            value: '${r.questionsCount}',
                            valueColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const TabBar(
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.liveDarkMuted,
                indicatorColor: AppColors.liveAccent,
                dividerColor: AppColors.liveDarkBorder,
                splashFactory: NoSplash.splashFactory,
                overlayColor: WidgetStatePropertyAll(Colors.transparent),
                tabs: [
                  Tab(text: 'Лидерборд'),
                  Tab(text: 'Разбор вопросов'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _LeaderboardTabContent(top: r.top),
                    AttemptReviewBody(attemptId: attemptId, dark: true),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => context.pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.liveAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Готово',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

