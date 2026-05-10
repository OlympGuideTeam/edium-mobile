part of 'test_monitoring_state.dart';

class TestMonitoringError extends TestMonitoringState {
  final String message;
  const TestMonitoringError(this.message);
  @override
  List<Object?> get props => [message];
}

