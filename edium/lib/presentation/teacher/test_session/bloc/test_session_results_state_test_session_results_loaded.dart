part of 'test_session_results_state.dart';

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


  final String? sessionStatus;


  final DateTime? startedAt;


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

