import 'package:edium/domain/usecases/test_session/get_attempt_review_usecase.dart';
import 'package:edium/domain/usecases/test_session/grade_submission_usecase.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_event.dart';
import 'package:edium/presentation/teacher/grade_attempt/bloc/teacher_grade_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TeacherGradeBloc extends Bloc<TeacherGradeEvent, TeacherGradeState> {
  final GetAttemptReviewUsecase _getReview;
  final GradeSubmissionUsecase _gradeAttempt;

  TeacherGradeBloc({
    required GetAttemptReviewUsecase getReview,
    required GradeSubmissionUsecase gradeSubmission,
  })  : _getReview = getReview,
        _gradeAttempt = gradeSubmission,
        super(const TeacherGradeInitial()) {
    on<LoadTeacherGradeEvent>(_onLoad);
    on<UpdateLocalGradeEvent>(_onUpdateLocal);
    on<CompleteGradingEvent>(_onComplete);
  }

  Future<void> _onLoad(
    LoadTeacherGradeEvent event,
    Emitter<TeacherGradeState> emit,
  ) async {
    emit(const TeacherGradeLoading());
    try {
      final review = await _getReview(event.attemptId);
      // Предзаполняем localGrades оценками из сервера (LLM/auto)
      final initialGrades = <String, ({double score, String? feedback})>{};
      for (final a in review.answers) {
        if (a.finalScore != null) {
          initialGrades[a.submissionId] = (
            score: a.finalScore!,
            feedback: a.finalFeedback,
          );
        }
      }
      emit(TeacherGradeLoaded(review: review, localGrades: initialGrades));
    } catch (e) {
      emit(TeacherGradeError(e.toString()));
    }
  }

  void _onUpdateLocal(
    UpdateLocalGradeEvent event,
    Emitter<TeacherGradeState> emit,
  ) {
    final current = state;
    if (current is! TeacherGradeLoaded) return;
    final updated = Map<String, ({double score, String? feedback})>.from(
      current.localGrades,
    );
    updated[event.submissionId] = (
      score: event.score,
      feedback: event.feedback,
    );
    emit(current.copyWith(localGrades: updated));
  }

  Future<void> _onComplete(
    CompleteGradingEvent event,
    Emitter<TeacherGradeState> emit,
  ) async {
    final current = state;
    if (current is! TeacherGradeLoaded) return;
    emit(current.copyWith(isSaving: true));
    try {
      await _gradeAttempt(
        attemptId: event.attemptId,
        grades: current.localGrades.entries
            .map((e) => (
                  submissionId: e.key,
                  score: e.value.score,
                  feedback: e.value.feedback,
                ))
            .toList(),
      );
      emit(const TeacherGradeCompleted());
    } catch (e) {
      emit(current.copyWith(isSaving: false, saveError: e.toString()));
    }
  }
}
