import 'package:edium/domain/entities/attempt_summary.dart';
import 'package:equatable/equatable.dart';

part 'test_session_results_state_test_session_results_state.dart';
part 'test_session_results_state_test_session_results_initial.dart';
part 'test_session_results_state_test_session_results_loading.dart';
part 'test_session_results_state_test_session_results_loaded.dart';
part 'test_session_results_state_test_session_results_deleted.dart';
part 'test_session_results_state_test_session_results_error.dart';


class StudentRow extends Equatable {
  final String userId;
  final String displayName;
  final AttemptSummary? attempt;

  const StudentRow({
    required this.userId,
    required this.displayName,
    this.attempt,
  });

  @override
  List<Object?> get props => [userId, displayName, attempt];
}

