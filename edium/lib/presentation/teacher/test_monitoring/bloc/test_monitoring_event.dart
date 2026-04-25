import 'package:equatable/equatable.dart';

abstract class TestMonitoringEvent extends Equatable {
  const TestMonitoringEvent();
  @override
  List<Object?> get props => [];
}

class LoadTestMonitoringEvent extends TestMonitoringEvent {
  final String sessionId;
  final String classId;
  final String title;
  final bool needsManualGrading;

  const LoadTestMonitoringEvent({
    required this.sessionId,
    required this.classId,
    required this.title,
    required this.needsManualGrading,
  });

  @override
  List<Object?> get props => [sessionId, classId, title, needsManualGrading];
}

class RefreshTestMonitoringEvent extends TestMonitoringEvent {
  const RefreshTestMonitoringEvent();
}
