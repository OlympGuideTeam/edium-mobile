import 'package:edium/domain/usecases/test_session/complete_attempt_usecase.dart';
import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/domain/usecases/test_session/grade_submission_usecase.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_event.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherGradeBloc extends Bloc<TeacherGradeEvent, TeacherGradeState> {
  final GetAttemptReviewUsecase _getReview;
  final GradeSubmissionUsecase _gradeSubmission;
  final CompleteAttemptUsecase _completeAttempt;

  TeacherGradeBloc({
    required GetAttemptReviewUsecase getReview,
    required GradeSubmissionUsecase gradeSubmission,
    required CompleteAttemptUsecase completeAttempt,
  })  : _getReview = getReview,
        _gradeSubmission = gradeSubmission,
        _completeAttempt = completeAttempt,
        super(const TeacherGradeInitial()) {
    on<LoadTeacherGradeEvent>(_onLoad);
    on<SubmitGradesEvent>(_onSubmit);
    on<CompleteGradingEvent>(_onComplete);
  }

  Future<void> _onLoad(
    LoadTeacherGradeEvent event,
    Emitter<TeacherGradeState> emit,
  ) async {
    emit(const TeacherGradeLoading());
    try {
      final review = await _getReview(event.attemptId);
      emit(TeacherGradeLoaded(review: review));
    } catch (e) {
      emit(TeacherGradeError(e.toString()));
    }
  }

  Future<void> _onSubmit(
    SubmitGradesEvent event,
    Emitter<TeacherGradeState> emit,
  ) async {
    final current = state;
    if (current is! TeacherGradeLoaded) return;
    emit(current.copyWith(isSaving: true));
    try {
      for (final grade in event.grades) {
        await _gradeSubmission(
          attemptId: event.attemptId,
          submissionId: grade.submissionId,
          score: grade.score,
          feedback: grade.feedback,
        );
      }
      await _completeAttempt(event.attemptId);
      emit(const TeacherGradeCompleted());
    } catch (e) {
      emit(current.copyWith(isSaving: false, saveError: e.toString()));
    }
  }

  Future<void> _onComplete(
    CompleteGradingEvent event,
    Emitter<TeacherGradeState> emit,
  ) async {
    final current = state;
    if (current is! TeacherGradeLoaded) return;
    emit(current.copyWith(isSaving: true));
    try {
      await _completeAttempt(event.attemptId);
      emit(const TeacherGradeCompleted());
    } catch (e) {
      emit(current.copyWith(isSaving: false, saveError: e.toString()));
    }
  }
}
