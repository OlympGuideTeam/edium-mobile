import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:equatable/equatable.dart';

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

abstract class TestMonitoringState extends Equatable {
  const TestMonitoringState();
  @override
  List<Object?> get props => [];
}

class TestMonitoringInitial extends TestMonitoringState {
  const TestMonitoringInitial();
}

class TestMonitoringLoading extends TestMonitoringState {
  const TestMonitoringLoading();
}

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

class TestMonitoringError extends TestMonitoringState {
  final String message;
  const TestMonitoringError(this.message);
  @override
  List<Object?> get props => [message];
}
