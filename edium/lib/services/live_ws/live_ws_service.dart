import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:edium/core/config/api_config.dart';
import 'package:edium/domain/entities/live_ws_event.dart';
import 'package:flutter/foundation.dart';


class LiveWsService {
  WebSocket? _socket;
  StreamSubscription? _sub;
  final StreamController<LiveWsEvent> _controller =
      StreamController.broadcast(sync: true);

  bool _disposed = false;

  Stream<LiveWsEvent> get events => _controller.stream;

  bool get isConnected =>
      _socket != null &&
      _socket!.readyState == WebSocket.open;

  Future<void> connect(String sessionId, String token) async {
    await disconnect();
    _disposed = false;

    final wsUrl = _buildWsUrl(sessionId, token);
    debugPrint('[LiveWS] Connecting to $wsUrl');

    _socket = await WebSocket.connect(wsUrl);
    debugPrint('[LiveWS] Connected');

    _sub = _socket!.listen(
      _onData,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: false,
    );
  }

  void send(Map<String, dynamic> message) {
    if (!isConnected) return;
    final json = jsonEncode(message);
    debugPrint('[LiveWS →] $json');
    _socket!.add(json);
  }

  Future<void> disconnect() async {
    _disposed = true;
    await _sub?.cancel();
    _sub = null;
    await _socket?.close(WebSocketStatus.normalClosure);
    _socket = null;
  }

  void dispose() {
    disconnect();
    _controller.close();
  }


  void _onData(dynamic raw) {
    if (_disposed) return;
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      debugPrint('[LiveWS ←] $raw');
      final event = parseLiveWsEvent(json);
      if (event != null) _controller.add(event);
    } catch (e) {
      debugPrint('[LiveWS] parse error: $e');
    }
  }

  void _onDone() {
    debugPrint('[LiveWS] Done (code ${_socket?.closeCode})');
    if (!_disposed) _controller.add(LiveWsDisconnected());
  }

  void _onError(Object error) {
    debugPrint('[LiveWS] Error: $error');
    if (!_disposed) _controller.add(LiveWsDisconnected());
  }

  String _buildWsUrl(String sessionId, String token) {
    final httpBase = ApiConfig.baseUrl;
    final wsBase = httpBase
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://')
        .replaceAll(RegExp(r'/$'), '');
    final url = '$wsBase/riddler/v1/sessions/$sessionId/live/ws?token=${Uri.encodeComponent(token)}';
    debugPrint('[LiveWS] URL: $wsBase/riddler/v1/sessions/$sessionId/live/ws?token=[${token.isEmpty ? "EMPTY" : "${token.length}chars"}]');
    return url;
  }
}
