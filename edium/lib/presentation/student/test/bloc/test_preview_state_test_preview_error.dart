part of 'test_preview_state.dart';

class TestPreviewError extends TestPreviewState {
  final String message;
  const TestPreviewError(this.message);
  @override
  List<Object?> get props => [message];
}

