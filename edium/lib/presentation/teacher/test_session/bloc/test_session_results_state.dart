import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:equatable/equatable.dart';

class StudentRow extends Equatable {
  final String userId;
  final String displayName;
  final AttemptSummary? attempt;

  const StudentRow({
    required this.userId,
    required this.displayName,
    this.attempt,
  });

  @override
  List<Object?> get props => [userId, displayName, attempt];
}

abstract class TestSessionResultsState extends Equatable {
  const TestSessionResultsState();
  @override
  List<Object?> get props => [];
}

class TestSessionResultsInitial extends TestSessionResultsState {
  const TestSessionResultsInitial();
}

class TestSessionResultsLoading extends TestSessionResultsState {
  const TestSessionResultsLoading();
}

class TestSessionResultsLoaded extends TestSessionResultsState {
  final String sessionId;
  final String title;
  final List<StudentRow> rows;
  final int completedCount;
  final int totalCount;
  final double? averageScorePct;
  final bool canDelete;
  final bool canPublish;
  final bool isDeleting;
  final bool isFinishing;
  final bool isPublishing;

  /// not_started | active | finished — из /sessions/statuses
  final String? sessionStatus;

  /// Дата открытия доступа (из payload сессии).
  final DateTime? startedAt;

  /// Дедлайн сдачи (из payload сессии).
  final DateTime? finishedAt;

  const TestSessionResultsLoaded({
    required this.sessionId,
    required this.title,
    required this.rows,
    required this.completedCount,
    required this.totalCount,
    required this.averageScorePct,
    required this.canDelete,
    required this.canPublish,
    this.isDeleting = false,
    this.isFinishing = false,
    this.isPublishing = false,
    this.sessionStatus,
    this.startedAt,
    this.finishedAt,
  });

  TestSessionResultsLoaded copyWith({
    bool? isDeleting,
    bool? isFinishing,
    bool? isPublishing,
    String? sessionStatus,
  }) =>
      TestSessionResultsLoaded(
        sessionId: sessionId,
        title: title,
        rows: rows,
        completedCount: completedCount,
        totalCount: totalCount,
        averageScorePct: averageScorePct,
        canDelete: canDelete,
        canPublish: canPublish,
        isDeleting: isDeleting ?? this.isDeleting,
        isFinishing: isFinishing ?? this.isFinishing,
        isPublishing: isPublishing ?? this.isPublishing,
        sessionStatus: sessionStatus ?? this.sessionStatus,
        startedAt: startedAt,
        finishedAt: finishedAt,
      );

  @override
  List<Object?> get props => [
        sessionId,
        title,
        rows,
        completedCount,
        totalCount,
        averageScorePct,
        canDelete,
        canPublish,
        isDeleting,
        isFinishing,
        isPublishing,
        sessionStatus,
        startedAt,
        finishedAt,
      ];
}

class TestSessionResultsDeleted extends TestSessionResultsState {
  const TestSessionResultsDeleted();
}

class TestSessionResultsError extends TestSessionResultsState {
  final String message;
  const TestSessionResultsError(this.message);
  @override
  List<Object?> get props => [message];
}
