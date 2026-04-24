import 'package:edium/domain/entities/test_session_meta.dart';
import 'package:equatable/equatable.dart';

abstract class TestPreviewEvent extends Equatable {
  const TestPreviewEvent();
  @override
  List<Object?> get props => [];
}

class LoadTestPreviewEvent extends TestPreviewEvent {
  final TestSessionMeta meta;

  /// Если у студента уже есть завершённая попытка — передаём её id из
  /// `CourseItem.attemptId`, чтобы подтянуть review и показать "Посмотреть результат".
  final String? initialAttemptId;

  const LoadTestPreviewEvent({required this.meta, this.initialAttemptId});

  @override
  List<Object?> get props => [meta, initialAttemptId];
}
