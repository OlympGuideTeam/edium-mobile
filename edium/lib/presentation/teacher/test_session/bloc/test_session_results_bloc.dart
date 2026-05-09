import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/entities/live_session.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/entities/session_status_item.dart';
import 'package:edium/domain/repositories/course_repository.dart';
import 'package:edium/domain/repositories/live_repository.dart';
import 'package:edium/domain/repositories/test_session_repository.dart';
import 'package:edium/domain/usecases/test_session/list_session_attempts_usecase.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_event.dart';
import 'package:edium/presentation/teacher/test_session/bloc/test_session_results_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestSessionResultsBloc
    extends Bloc<TestSessionResultsEvent, TestSessionResultsState> {
  final ListSessionAttemptsUsecase _listAttempts;
  final ILiveRepository _liveRepo;
  final ICourseRepository _courseRepo;
  final ITestSessionRepository _testSessionRepo;

  String? _sessionId;
  String? _moduleId;
  String? _courseItemId;
  String _title = '';
  DateTime? _startedAt;
  DateTime? _finishedAt;

  TestSessionResultsBloc({
    required ListSessionAttemptsUsecase listAttempts,
    required ILiveRepository liveRepo,
    required ICourseRepository courseRepo,
    required ITestSessionRepository testSessionRepo,
  })  : _listAttempts = listAttempts,
        _liveRepo = liveRepo,
        _courseRepo = courseRepo,
        _testSessionRepo = testSessionRepo,
        super(const TestSessionResultsInitial()) {
    on<LoadSessionResultsEvent>((e, emit) async {
      _sessionId = e.sessionId;
      _moduleId = e.moduleId;
      _courseItemId = e.courseItemId;
      _title = e.title;
      _startedAt = e.startedAt;
      _finishedAt = e.finishedAt;
      await _load(emit);
    });
    on<RefreshSessionResultsEvent>((e, emit) async {
      await _load(emit);
    });
    on<DeleteSessionEvent>(_onDelete);
    on<FinishSessionEvent>(_onFinish);
    on<PublishSessionEvent>(_onPublish);
  }

  Future<void> _load(Emitter<TestSessionResultsState> emit) async {
    final sid = _sessionId;
    if (sid == null) return;
    emit(const TestSessionResultsLoading());
    try {
      final mid = _moduleId;

      List<dynamic> results;
      List<LiveRosterMember> rosterMembers = [];

      if (mid != null) {
        final futures = await Future.wait<dynamic>([
          _listAttempts(sid),
          _liveRepo.getModuleRoster(mid),
          _courseRepo.getSessionStatuses([sid]),
        ]);
        results = futures;
        rosterMembers = futures[1] as List<LiveRosterMember>;
      } else {
        final futures = await Future.wait<dynamic>([
          _listAttempts(sid),
          _courseRepo.getSessionStatuses([sid]),
        ]);
        results = futures;
        final attemptsForRoster = results[0] as List<AttemptSummary>;
        final userIds = attemptsForRoster.map((a) => a.userId).toSet().toList();
        if (userIds.isNotEmpty) {
          try {
            rosterMembers = await _liveRepo.getUsersRoster(userIds);
          } catch (e, st) {
            debugPrint('[TestSessionResultsBloc] users roster: $e\n$st');
          }
        }
      }

      final attempts = results[0] as List<AttemptSummary>;
      final statusMap = results[mid != null ? 2 : 1] as Map<String, SessionStatusItem>;
      final sessionStatusItem = statusMap[sid];
      final sessionStatus = sessionStatusItem?.status;

      // Строим map userId → attempt для быстрого поиска
      final attemptMap = <String, AttemptSummary>{
        for (final a in attempts) a.userId: a,
      };

      // С moduleId — весь класс из Caesar module roster + попытки вне ростера.
      // Без moduleId (уведомления / deep link) — только попытки, имена из GET users/roster.
      final List<StudentRow> rows;
      if (mid != null && rosterMembers.isNotEmpty) {
        final rosterUserIds = <String>{};
        final rosterRows = rosterMembers.map((m) {
          rosterUserIds.add(m.userId);
          return StudentRow(
            userId: m.userId,
            displayName: m.name,
            attempt: attemptMap[m.userId],
          );
        }).toList();
        final extraRows = attempts
            .where((a) => !rosterUserIds.contains(a.userId))
            .map((a) => StudentRow(
                  userId: a.userId,
                  displayName: a.userName ?? a.userId,
                  attempt: a,
                ))
            .toList();
        rows = [...rosterRows, ...extraRows];
      } else {
        final nameByUserId = {
          for (final m in rosterMembers) m.userId: m.name,
        };
        rows = attempts
            .map((a) => StudentRow(
                  userId: a.userId,
                  displayName:
                      nameByUserId[a.userId] ?? a.userName ?? a.userId,
                  attempt: a,
                ))
            .toList();
      }

      final completedOrPublished = attempts
          .where((a) =>
              a.status == AttemptStatus.completed ||
              a.status == AttemptStatus.published)
          .toList();
      final totalCount = rows.length;
      final avgPct = completedOrPublished.isEmpty
          ? null
          : (completedOrPublished
                  .map((a) => a.score ?? 0)
                  .fold<double>(0, (s, v) => s + v) /
              completedOrPublished.length);

      // Удалять можно только если нет ни одной попытки.
      final canDelete = attempts.isEmpty &&
          _courseItemId != null &&
          (sessionStatus == null ||
              sessionStatus == 'not_started' ||
              sessionStatus == 'waiting');

      // Публиковать можно только после завершения сессии (finished), когда все
      // попытки хотя бы graded и ни одна ещё не published.
      final canPublish = sessionStatus == 'finished' &&
          attempts.isNotEmpty &&
          !attempts.any((a) => a.status == AttemptStatus.published) &&
          attempts.every((a) =>
              a.status == AttemptStatus.graded ||
              a.status == AttemptStatus.completed);

      emit(TestSessionResultsLoaded(
        sessionId: sid,
        title: _title,
        rows: rows,
        completedCount: completedOrPublished.length,
        totalCount: totalCount,
        averageScorePct: avgPct,
        canDelete: canDelete,
        canPublish: canPublish,
        sessionStatus: sessionStatus,
        startedAt: _startedAt,
        finishedAt: _finishedAt,
      ));
    } catch (e) {
      emit(TestSessionResultsError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteSessionEvent event,
    Emitter<TestSessionResultsState> emit,
  ) async {
    final itemId = _courseItemId;
    if (itemId == null) return;
    if (state is! TestSessionResultsLoaded) return;
    emit((state as TestSessionResultsLoaded).copyWith(isDeleting: true));
    try {
      await _courseRepo.deleteItem(itemId);
      emit(const TestSessionResultsDeleted());
    } catch (e) {
      emit(TestSessionResultsError(e.toString()));
    }
  }

  Future<void> _onFinish(
    FinishSessionEvent event,
    Emitter<TestSessionResultsState> emit,
  ) async {
    final sid = _sessionId;
    if (sid == null) return;
    if (state is! TestSessionResultsLoaded) return;
    emit((state as TestSessionResultsLoaded).copyWith(isFinishing: true));
    try {
      await _testSessionRepo.finishSession(sid);
      await _load(emit);
    } catch (e) {
      emit(TestSessionResultsError(e.toString()));
    }
  }

  Future<void> _onPublish(
    PublishSessionEvent event,
    Emitter<TestSessionResultsState> emit,
  ) async {
    final sid = _sessionId;
    if (sid == null) return;
    if (state is! TestSessionResultsLoaded) return;
    emit((state as TestSessionResultsLoaded).copyWith(isPublishing: true));
    try {
      await _testSessionRepo.publishSession(sid);
      await _load(emit);
    } catch (e) {
      emit(TestSessionResultsError(e.toString()));
    }
  }
}
