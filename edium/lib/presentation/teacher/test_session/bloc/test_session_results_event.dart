import 'package:equatable/equatable.dart';

part 'test_session_results_event_load_session_results_event.dart';
part 'test_session_results_event_refresh_session_results_event.dart';
part 'test_session_results_event_delete_session_event.dart';
part 'test_session_results_event_finish_session_event.dart';
part 'test_session_results_event_publish_session_event.dart';


abstract class TestSessionResultsEvent extends Equatable {
  const TestSessionResultsEvent();
  @override
  List<Object?> get props => [];
}

