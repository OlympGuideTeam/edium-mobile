part of 'live_ws_event.dart';

class LiveWsError extends LiveWsEvent {
  final String code;
  final String? message;
  final String? clientMsgId;

  LiveWsError({required this.code, this.message, this.clientMsgId});

  factory LiveWsError.fromJson(Map<String, dynamic> data) => LiveWsError(
        code: data['code'] as String? ?? 'UNKNOWN',
        message: data['message'] as String?,
        clientMsgId: data['client_msg_id'] as String?,
      );
}

