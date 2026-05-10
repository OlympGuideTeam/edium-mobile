part of 'test_monitoring_screen.dart';

class _LoadedBody extends StatelessWidget {
  final TestMonitoringLoaded state;
  final String sessionId;

  const _LoadedBody({required this.state, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final notStarted = state.rows.where((r) => r.status == null).length;
    final inProgress =
        state.rows.where((r) => r.status == AttemptStatus.inProgress).length;
    final finished = state.finishedCount;

    return RefreshIndicator(
      color: AppColors.mono700,
      onRefresh: () async => context
          .read<TestMonitoringBloc>()
          .add(const RefreshTestMonitoringEvent()),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppDimens.screenPaddingH,
          0,
          AppDimens.screenPaddingH,
          24,
        ),
        children: [
          const SizedBox(height: 4),
          Text(state.title,
              style: AppTextStyles.screenTitle.copyWith(fontSize: 22)),
          const SizedBox(height: 16),
          _StatsStrip(
              notStarted: notStarted,
              inProgress: inProgress,
              finished: finished),
          if (state.needsManualGrading) ...[
            const SizedBox(height: 12),
            const _GradingBanner(),
          ],
          const SizedBox(height: 20),
          if (state.rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text('Нет студентов в классе',
                    style: AppTextStyles.screenSubtitle),
              ),
            )
          else
            ...state.rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _MonitoringRowTile(
                  row: row,
                  needsManualGrading: state.needsManualGrading,
                  onTap: _buildOnTap(context, row),
                ),
              ),
            ),
        ],
      ),
    );
  }

  VoidCallback? _buildOnTap(BuildContext context, MonitoringRow row) {
    if (row.attemptId == null) return null;
    if (row.needsTeacherAction) {
      return () => context
          .push('/test/$sessionId/attempts/${row.attemptId}/grade');
    }
    if (row.status == AttemptStatus.completed) {
      return () =>
          context.push('/test/$sessionId/attempts/${row.attemptId}');
    }
    return null;
  }
}

