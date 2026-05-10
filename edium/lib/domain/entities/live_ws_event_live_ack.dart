part of 'live_ws_event.dart';

class LiveAck extends LiveWsEvent {
  final String clientMsgId;
  LiveAck({required this.clientMsgId});
  factory LiveAck.fromJson(Map<String, dynamic> data) =>
      LiveAck(clientMsgId: data['client_msg_id'] as String);
}

