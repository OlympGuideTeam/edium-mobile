import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:edium/domain/entities/class_detail.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/repositories/class_repository.dart';
import 'package:edium/domain/usecases/test_session/list_session_attempts_usecase.dart';
import 'package:edium/presentation/teacher/test_monitoring/bloc/test_monitoring_event.dart';
import 'package:edium/presentation/teacher/test_monitoring/bloc/test_monitoring_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestMonitoringBloc
    extends Bloc<TestMonitoringEvent, TestMonitoringState> {
  final ListSessionAttemptsUsecase _listAttempts;
  final IClassRepository _classRepo;

  String? _sessionId;
  String? _classId;
  String _title = '';
  bool _needsManualGrading = false;

  TestMonitoringBloc({
    required ListSessionAttemptsUsecase listAttempts,
    required IClassRepository classRepo,
  })  : _listAttempts = listAttempts,
        _classRepo = classRepo,
        super(const TestMonitoringInitial()) {
    on<LoadTestMonitoringEvent>(_onLoad);
    on<RefreshTestMonitoringEvent>(_onRefresh);
  }

  Future<void> _onLoad(
    LoadTestMonitoringEvent event,
    Emitter<TestMonitoringState> emit,
  ) async {
    _sessionId = event.sessionId;
    _classId = event.classId;
    _title = event.title;
    _needsManualGrading = event.needsManualGrading;
    await _load(emit);
  }

  Future<void> _onRefresh(
    RefreshTestMonitoringEvent event,
    Emitter<TestMonitoringState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<TestMonitoringState> emit) async {
    final sid = _sessionId;
    final cid = _classId;
    if (sid == null || cid == null) return;

    emit(const TestMonitoringLoading());
    try {
      final results = await Future.wait<dynamic>([
        _listAttempts(sid),
        _classRepo.getClassDetail(classId: cid),
      ]);

      final attempts = results[0] as List<AttemptSummary>;
      final classDetail = results[1] as ClassDetail;

      final attemptsMap = {for (final a in attempts) a.userId: a};

      final rows = classDetail.students.map((student) {
        final attempt = attemptsMap[student.id];
        return MonitoringRow(
          userId: student.id,
          displayName: student.fullName.isNotEmpty ? student.fullName : student.id,
          status: attempt?.status,
          attemptId: attempt?.attemptId,
          score: attempt?.score,
        );
      }).toList()
        ..sort(_compareRows);

      final finishedCount = rows.where((r) => r.isFinished).length;
      final hasActive = rows.any((r) => r.isActive);
      final allFinished = attempts.isNotEmpty && !hasActive;

      emit(TestMonitoringLoaded(
        sessionId: sid,
        title: _title,
        needsManualGrading: _needsManualGrading,
        rows: rows,
        allFinished: allFinished,
        finishedCount: finishedCount,
        totalCount: rows.length,
      ));
    } catch (e) {
      emit(TestMonitoringError(e.toString()));
    }
  }


  int _compareRows(MonitoringRow a, MonitoringRow b) =>
      _priority(a).compareTo(_priority(b));

  int _priority(MonitoringRow r) => switch (r.status) {
        AttemptStatus.graded => 0,
        AttemptStatus.inProgress => 1,
        null => 2,
        AttemptStatus.grading => 3,
        AttemptStatus.completed => 4,
        AttemptStatus.published => 4,
      };
}
