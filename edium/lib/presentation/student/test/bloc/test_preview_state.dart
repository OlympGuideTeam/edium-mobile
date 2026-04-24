import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/entities/test_session_meta.dart';
import 'package:equatable/equatable.dart';

/// Итоговое состояние CTA на экране превью.
enum TestPreviewStatus {
  start,     // «Начать тест»
  resume,    // «Продолжить»
  locked,    // «Откроется DD MMM в HH:mm» (startedAt > now)
  expired,   // «Дедлайн истёк» (finishedAt < now и нет завершённого attempt)
  grading,   // «Ответы проверяются…» (grading/graded)
  completed, // «Посмотреть результат» (completed)
}

/// Чистая функция — покрыта unit-тестом.
TestPreviewStatus derivePreviewStatus({
  required TestSessionMeta meta,
  required bool hasActiveCache,
  required AttemptStatus? latestAttemptStatus,
  required DateTime now,
}) {
  if (latestAttemptStatus == AttemptStatus.completed) {
    return TestPreviewStatus.completed;
  }
  if (latestAttemptStatus == AttemptStatus.grading ||
      latestAttemptStatus == AttemptStatus.graded) {
    return TestPreviewStatus.grading;
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

class TestPreviewInitial extends TestPreviewState {
  const TestPreviewInitial();
}

class TestPreviewLoading extends TestPreviewState {
  const TestPreviewLoading();
}

class TestPreviewLoaded extends TestPreviewState {
  final TestSessionMeta meta;
  final TestPreviewStatus status;
  final AttemptReview? review;   // если есть attempt_id — для кнопки "к результату"
  final String? cachedAttemptId; // если восстанавливаем — берём id отсюда

  const TestPreviewLoaded({
    required this.meta,
    required this.status,
    this.review,
    this.cachedAttemptId,
  });

  @override
  List<Object?> get props => [meta, status, review, cachedAttemptId];
}

class TestPreviewError extends TestPreviewState {
  final String message;
  const TestPreviewError(this.message);
  @override
  List<Object?> get props => [message];
}
