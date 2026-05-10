part of 'review_session_screen.dart';

class _Loaded extends _State {
  final List<AttemptSummary> attempts;
  final bool isPublishing;
  final String? publishError;

  const _Loaded(
    this.attempts, {
    this.isPublishing = false,
    this.publishError,
  });

  @override
  List<Object?> get props => [attempts, isPublishing, publishError];

  _Loaded copyWith({
    List<AttemptSummary>? attempts,
    bool? isPublishing,
    String? publishError,
  }) =>
      _Loaded(
        attempts ?? this.attempts,
        isPublishing: isPublishing ?? this.isPublishing,
        publishError: publishError,
      );
}

