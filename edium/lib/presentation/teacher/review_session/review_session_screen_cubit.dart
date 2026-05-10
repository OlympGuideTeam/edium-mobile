part of 'review_session_screen.dart';

class _Cubit extends Cubit<_State> {
  final ListSessionAttemptsUsecase _usecase;
  final PublishSessionUsecase _publish;
  final String sessionId;

  _Cubit(this._usecase, this._publish, this.sessionId)
      : super(const _Loading()) {
    _load();
  }

  Future<void> refresh() => _load();

  Future<void> _load() async {
    emit(const _Loading());
    try {
      final all = await _usecase(sessionId);
      final reviewable = all
          .where((a) =>
              a.status == AttemptStatus.graded ||
              a.status == AttemptStatus.grading ||
              a.status == AttemptStatus.completed)
          .toList()
        ..sort((a, b) => _statusOrder(a.status) - _statusOrder(b.status));
      emit(_Loaded(reviewable));
    } catch (e) {
      emit(_Error(e.toString()));
    }
  }

  Future<void> publish() async {
    final current = state;
    if (current is! _Loaded) return;
    emit(current.copyWith(isPublishing: true, publishError: null));
    try {
      await _publish(sessionId);
      emit(const _Published());
    } catch (e) {
      emit(current.copyWith(isPublishing: false, publishError: e.toString()));
    }
  }


  static int _statusOrder(AttemptStatus s) {
    if (s == AttemptStatus.graded) return 0;
    if (s == AttemptStatus.grading) return 1;
    return 2;
  }
}

