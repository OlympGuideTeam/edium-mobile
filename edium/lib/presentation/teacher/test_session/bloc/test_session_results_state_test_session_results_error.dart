part of 'test_session_results_state.dart';

class TestSessionResultsError extends TestSessionResultsState {
  final String message;
  const TestSessionResultsError(this.message);
  @override
  List<Object?> get props => [message];
}

