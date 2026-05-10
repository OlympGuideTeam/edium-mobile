import 'package:equatable/equatable.dart';

part 'auth_event_app_started.dart';
part 'auth_event_send_otp_event.dart';
part 'auth_event_verify_otp_event.dart';
part 'auth_event_register_event.dart';
part 'auth_event_name_submitted_event.dart';
part 'auth_event_role_selected_event.dart';
part 'auth_event_logout_event.dart';
part 'auth_event_switch_to_role_event.dart';
part 'auth_event_session_expired_event.dart';


abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

