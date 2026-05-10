import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/entities/test_session_meta.dart';
import 'package:equatable/equatable.dart';

part 'test_preview_state_test_preview_initial.dart';
part 'test_preview_state_test_preview_loading.dart';
part 'test_preview_state_test_preview_loaded.dart';
part 'test_preview_state_test_preview_error.dart';



enum TestPreviewStatus {
  start,
  resume,
  locked,
  expired,
  grading,
  graded,
  published,
}


TestPreviewStatus derivePreviewStatus({
  required TestSessionMeta meta,
  required bool hasActiveCache,
  required AttemptStatus? latestAttemptStatus,
  required DateTime now,
}) {
  if (latestAttemptStatus == AttemptStatus.published) {
    return TestPreviewStatus.published;
  }
  if (latestAttemptStatus == AttemptStatus.grading) {
    return TestPreviewStatus.grading;
  }
  if (latestAttemptStatus == AttemptStatus.graded ||
      latestAttemptStatus == AttemptStatus.completed) {
    return TestPreviewStatus.graded;
  }
  if (meta.finishedAt != null && now.isAfter(meta.finishedAt!)) {
    return TestPreviewStatus.expired;
  }
  if (meta.startedAt != null && now.isBefore(meta.startedAt!)) {
    return TestPreviewStatus.locked;
  }
  if (hasActiveCache || latestAttemptStatus == AttemptStatus.inProgress) {
    return TestPreviewStatus.resume;
  }
  return TestPreviewStatus.start;
}

abstract class TestPreviewState extends Equatable {
  const TestPreviewState();
  @override
  List<Object?> get props => [];
}

