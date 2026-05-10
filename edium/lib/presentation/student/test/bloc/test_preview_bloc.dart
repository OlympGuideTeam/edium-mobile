import 'package:edium/domain/entities/attempt_review.dart';
import 'package:edium/domain/entities/quiz_attempt.dart' show AttemptStatus;
import 'package:edium/domain/entities/test_session_meta.dart';
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
      var meta = event.meta;


      if (meta.quizId != meta.sessionId) {
        try {
          final riddlerMeta = await _repo.getSessionMeta(
            quizId: meta.quizId,
            sessionIdFallback: meta.sessionId,
          );
          meta = TestSessionMeta(
            sessionId: meta.sessionId,
            quizId: riddlerMeta.quizId,
            title: riddlerMeta.title,
            description: riddlerMeta.description,
            questionCount: riddlerMeta.questionCount,
            needEvaluation: riddlerMeta.needEvaluation,
            totalTimeLimitSec: riddlerMeta.totalTimeLimitSec,
            shuffleQuestions: riddlerMeta.shuffleQuestions,
            startedAt: meta.startedAt ?? riddlerMeta.startedAt,
            finishedAt: meta.finishedAt ?? riddlerMeta.finishedAt,
          );
        } catch (_) {

        }
      }

      final now = DateTime.now();


      final cached = await _repo.readCachedAttempt(meta.sessionId);
      final hasActiveCache = cached != null && !cached.isExpired(now);


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


      if (meta.questionCount == 0) {
        final derived = (hasActiveCache ? cached.questions.length : null) ??
            review?.answers.length ??
            0;
        if (derived > 0) {
          meta = TestSessionMeta(
            sessionId: meta.sessionId,
            quizId: meta.quizId,
            title: meta.title,
            description: meta.description,
            questionCount: derived,
            needEvaluation: meta.needEvaluation,
            totalTimeLimitSec: meta.totalTimeLimitSec,
            shuffleQuestions: meta.shuffleQuestions,
            startedAt: meta.startedAt,
            finishedAt: meta.finishedAt,
          );
        }
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
