part of 'student_dashboard_cubit.dart';

class StudentDashboardLoaded extends StudentDashboardState {
  final StudentDashboard dashboard;
  final LiveSessionMeta? activeLive;

  const StudentDashboardLoaded(this.dashboard, {this.activeLive});

  @override
  List<Object?> get props => [dashboard, activeLive];

  StudentDashboardLoaded copyWithLive(LiveSessionMeta? live) =>
      StudentDashboardLoaded(dashboard, activeLive: live);
}

