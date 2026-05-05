import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';
import 'package:edium/domain/usecases/test_session/list_session_attempts_usecase.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_event.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestSessionResultsBloc
    extends Bloc<TestSessionResultsEvent, TestSessionResultsState> {
  final ListSessionAttemptsUsecase _listAttempts;
  final ITestSessionRepository _repo;
  final ILiveRepository _liveRepo;

  String? _sessionId;
  String? _moduleId;
  String _title = '';

  TestSessionResultsBloc({
    required ListSessionAttemptsUsecase listAttempts,
    required ITestSessionRepository repo,
    required ILiveRepository liveRepo,
  })  : _listAttempts = listAttempts,
        _repo = repo,
        _liveRepo = liveRepo,
        super(const TestSessionResultsInitial()) {
    on<LoadSessionResultsEvent>((e, emit) async {
      _sessionId = e.sessionId;
      _moduleId = e.moduleId;
      _title = e.title;
      await _load(emit);
    });
    on<RefreshSessionResultsEvent>((e, emit) async {
      await _load(emit);
    });
    on<DeleteSessionEvent>(_onDelete);
  }

  Future<void> _load(Emitter<TestSessionResultsState> emit) async {
    final sid = _sessionId;
    if (sid == null) return;
    emit(const TestSessionResultsLoading());
    try {
      final mid = _moduleId;
      final futures = await Future.wait<dynamic>([
        _listAttempts(sid),
        if (mid != null) _liveRepo.getModuleRoster(mid),
      ]);

      final attempts = futures[0] as List;
      final rosterMembers = (mid != null && futures.length > 1)
          ? futures[1] as List<LiveRosterMember>
          : <LiveRosterMember>[];

      final nameMap = {
        for (final m in rosterMembers) m.userId: m.name,
      };

      final rows = attempts
          .map((a) => StudentRow(
                userId: a.userId,
                displayName: nameMap[a.userId] ?? a.userName ?? a.userId,
                attempt: a,
              ))
          .toList();

      final completed = attempts
          .where((a) => a.status == AttemptStatus.completed)
          .toList();
      final totalCount = attempts.length;
      final avgPct = completed.isEmpty
          ? null
          : (completed
                  .map((a) => a.score ?? 0)
                  .fold<double>(0, (s, v) => s + v) /
              completed.length);

      emit(TestSessionResultsLoaded(
        sessionId: sid,
        title: _title,
        rows: rows,
        completedCount: completed.length,
        totalCount: totalCount,
        averageScorePct: avgPct,
        canDelete: totalCount == 0,
      ));
    } catch (e) {
      emit(TestSessionResultsError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteSessionEvent event,
    Emitter<TestSessionResultsState> emit,
  ) async {
    final sid = _sessionId;
    if (sid == null) return;
    if (state is! TestSessionResultsLoaded) return;
    emit((state as TestSessionResultsLoaded).copyWith(isDeleting: true));
    try {
      await _repo.deleteSession(sid);
      emit(const TestSessionResultsDeleted());
    } catch (e) {
      emit(TestSessionResultsError(e.toString()));
    }
  }
}
