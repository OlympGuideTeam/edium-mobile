part of 'live_ws_event.dart';

class LiveYouWereKicked extends LiveWsEvent {
  final String reason;
  LiveYouWereKicked({required this.reason});
  factory LiveYouWereKicked.fromJson(Map<String, dynamic> data) =>
      LiveYouWereKicked(reason: data['reason'] as String? ?? 'kicked_by_teacher');
}

