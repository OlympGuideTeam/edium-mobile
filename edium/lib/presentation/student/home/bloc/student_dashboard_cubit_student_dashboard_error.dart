part of 'student_dashboard_cubit.dart';

class StudentDashboardError extends StudentDashboardState {
  final String message;

  const StudentDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

