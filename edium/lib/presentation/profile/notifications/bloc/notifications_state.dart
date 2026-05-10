import 'package:edium/services/herald_api_service/herald_dto.dart';
import 'package:equatable/equatable.dart';

part 'notifications_state_notifications_initial.dart';
part 'notifications_state_notifications_loading.dart';
part 'notifications_state_notifications_loaded.dart';
part 'notifications_state_notifications_error.dart';


abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

