part of 'live_student_state.dart';

class LiveStudentResultsLoaded extends LiveStudentState {
  final LiveResultsStudent results;
  final LiveAttemptReview? review;
  LiveStudentResultsLoaded(this.results, {this.review});
}

