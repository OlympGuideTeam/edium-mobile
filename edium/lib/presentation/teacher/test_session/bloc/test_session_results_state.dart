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
  final bool isDeleting;

  const TestSessionResultsLoaded({
    required this.sessionId,
    required this.title,
    required this.rows,
    required this.completedCount,
    required this.totalCount,
    required this.averageScorePct,
    required this.canDelete,
    this.isDeleting = false,
  });

  TestSessionResultsLoaded copyWith({bool? isDeleting}) =>
      TestSessionResultsLoaded(
        sessionId: sessionId,
        title: title,
        rows: rows,
        completedCount: completedCount,
        totalCount: totalCount,
        averageScorePct: averageScorePct,
        canDelete: canDelete,
        isDeleting: isDeleting ?? this.isDeleting,
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
        isDeleting,
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
