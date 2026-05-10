import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:equatable/equatable.dart';

part 'test_monitoring_state_test_monitoring_state.dart';
part 'test_monitoring_state_test_monitoring_initial.dart';
part 'test_monitoring_state_test_monitoring_loading.dart';
part 'test_monitoring_state_test_monitoring_loaded.dart';
part 'test_monitoring_state_test_monitoring_error.dart';


class MonitoringRow extends Equatable {
  final String userId;
  final String displayName;
  final AttemptStatus? status;
  final String? attemptId;
  final double? score;

  const MonitoringRow({
    required this.userId,
    required this.displayName,
    this.status,
    this.attemptId,
    this.score,
  });

  bool get isFinished =>
      status == AttemptStatus.grading ||
      status == AttemptStatus.graded ||
      status == AttemptStatus.completed;

  bool get isActive => status == AttemptStatus.inProgress;

  bool get needsTeacherAction => status == AttemptStatus.graded;

  @override
  List<Object?> get props => [userId, displayName, status, attemptId, score];
}

