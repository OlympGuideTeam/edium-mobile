part of 'student_dashboard_cubit.dart';

sealed class StudentDashboardState extends Equatable {
  const StudentDashboardState();

  @override
  List<Object?> get props => [];
}

class StudentDashboardInitial extends StudentDashboardState {
  const StudentDashboardInitial();
}

class StudentDashboardLoading extends StudentDashboardState {
  const StudentDashboardLoading();
}

class StudentDashboardLoaded extends StudentDashboardState {
  final StudentDashboard dashboard;
  final LiveSessionMeta? activeLive;

  const StudentDashboardLoaded(this.dashboard, {this.activeLive});

  @override
  List<Object?> get props => [dashboard, activeLive];

  StudentDashboardLoaded copyWithLive(LiveSessionMeta? live) =>
      StudentDashboardLoaded(dashboard, activeLive: live);
}

class StudentDashboardError extends StudentDashboardState {
  final String message;

  const StudentDashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
