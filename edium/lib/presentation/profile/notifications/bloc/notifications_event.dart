import 'package:equatable/equatable.dart';

part 'notifications_event_load_notifications_event.dart';
part 'notifications_event_toggle_push_event.dart';
part 'notifications_event_mark_read_event.dart';


abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

