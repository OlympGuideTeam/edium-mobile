import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/repositories/test_session_repository.dart';
import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_event.dart';
import 'package:edium/presentation/student/test/bloc/test_preview_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TestPreviewBloc extends Bloc<TestPreviewEvent, TestPreviewState> {
  final ITestSessionRepository _repo;
  final GetAttemptReviewUsecase _getReview;

  TestPreviewBloc({
    required ITestSessionRepository repo,
    required GetAttemptReviewUsecase getReview,
  })  : _repo = repo,
        _getReview = getReview,
        super(const TestPreviewInitial()) {
    on<LoadTestPreviewEvent>(_onLoad);
  }

  Future<void> _onLoad(
    LoadTestPreviewEvent event,
    Emitter<TestPreviewState> emit,
  ) async {
    emit(const TestPreviewLoading());
    try {
      final meta = event.meta;
      final now = DateTime.now();

      // 1. Локальный кэш попытки (in-progress)
      final cached = await _repo.readCachedAttempt(meta.sessionId);
      final hasActiveCache = cached != null && !cached.isExpired(now);

      // 2. Если Caesar дал attemptId — подтягиваем review для актуального статуса
      //    (completed / grading / graded / in_progress).
      //    Если /review вернёт 403 для in_progress — трактуем как inProgress.
      AttemptReview? review;
      AttemptStatus? latestStatus;
      final aid = event.initialAttemptId;
      if (aid != null) {
        try {
          review = await _getReview(aid);
          latestStatus = review.status;
        } catch (_) {
          latestStatus = AttemptStatus.inProgress;
        }
      } else if (hasActiveCache) {
        latestStatus = AttemptStatus.inProgress;
      }

      final status = derivePreviewStatus(
        meta: meta,
        hasActiveCache: hasActiveCache,
        latestAttemptStatus: latestStatus,
        now: now,
      );

      emit(TestPreviewLoaded(
        meta: meta,
        status: status,
        review: review,
        cachedAttemptId: hasActiveCache ? cached.attemptId : null,
      ));
    } catch (e) {
      emit(TestPreviewError(e.toString()));
    }
  }
}
