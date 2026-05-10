part of 'test_monitoring_state.dart';

class TestMonitoringLoaded extends TestMonitoringState {
  final String sessionId;
  final String title;
  final bool needsManualGrading;
  final List<MonitoringRow> rows;
  final bool allFinished;
  final int finishedCount;
  final int totalCount;

  const TestMonitoringLoaded({
    required this.sessionId,
    required this.title,
    required this.needsManualGrading,
    required this.rows,
    required this.allFinished,
    required this.finishedCount,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [
        sessionId,
        title,
        needsManualGrading,
        rows,
        allFinished,
        finishedCount,
        totalCount,
      ];
}

