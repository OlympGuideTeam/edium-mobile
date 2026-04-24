import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/entities/test_session_meta.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestSessionMeta meta({
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return TestSessionMeta(
      sessionId: 's',
      quizId: 'q',
      title: 't',
      questionCount: 3,
      needEvaluation: false,
      startedAt: startedAt,
      finishedAt: finishedAt,
    );
  }

  final now = DateTime.utc(2026, 4, 22, 12);

  test('completed имеет высший приоритет', () {
    final s = derivePreviewStatus(
      meta: meta(finishedAt: now.subtract(const Duration(days: 1))),
      hasActiveCache: true,
      latestAttemptStatus: AttemptStatus.completed,
      now: now,
    );
    expect(s, TestPreviewStatus.completed);
  });

  test('grading выше expired', () {
    final s = derivePreviewStatus(
      meta: meta(finishedAt: now.subtract(const Duration(days: 1))),
      hasActiveCache: false,
      latestAttemptStatus: AttemptStatus.grading,
      now: now,
    );
    expect(s, TestPreviewStatus.grading);
  });

  test('graded тоже grading', () {
    final s = derivePreviewStatus(
      meta: meta(),
      hasActiveCache: false,
      latestAttemptStatus: AttemptStatus.graded,
      now: now,
    );
    expect(s, TestPreviewStatus.grading);
  });

  test('expired когда finishedAt < now и нет attempt', () {
    final s = derivePreviewStatus(
      meta: meta(finishedAt: now.subtract(const Duration(minutes: 1))),
      hasActiveCache: false,
      latestAttemptStatus: null,
      now: now,
    );
    expect(s, TestPreviewStatus.expired);
  });

  test('locked когда startedAt > now', () {
    final s = derivePreviewStatus(
      meta: meta(startedAt: now.add(const Duration(hours: 1))),
      hasActiveCache: false,
      latestAttemptStatus: null,
      now: now,
    );
    expect(s, TestPreviewStatus.locked);
  });

  test('resume когда есть активный кэш', () {
    final s = derivePreviewStatus(
      meta: meta(),
      hasActiveCache: true,
      latestAttemptStatus: AttemptStatus.inProgress,
      now: now,
    );
    expect(s, TestPreviewStatus.resume);
  });

  test('resume когда in_progress без кэша (другое устройство)', () {
    final s = derivePreviewStatus(
      meta: meta(),
      hasActiveCache: false,
      latestAttemptStatus: AttemptStatus.inProgress,
      now: now,
    );
    expect(s, TestPreviewStatus.resume);
  });

  test('start по умолчанию', () {
    final s = derivePreviewStatus(
      meta: meta(),
      hasActiveCache: false,
      latestAttemptStatus: null,
      now: now,
    );
    expect(s, TestPreviewStatus.start);
  });
}
