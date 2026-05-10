part of 'course_live_notify_service.dart';

class CourseLiveNotifyService {
  WebSocket? _socket;
  StreamSubscription? _sub;

  final _controller = StreamController<List<CourseLiveItem>>.broadcast();
  final _items = <String, CourseLiveItem>{};

  bool _disposed = false;

  Stream<List<CourseLiveItem>> get stream => _controller.stream;

  List<CourseLiveItem> get currentItems => List.unmodifiable(_items.values);

  Future<void> connect(String token, List<String> courseIds) async {
    if (courseIds.isEmpty) return;
    await disconnect();
    _disposed = false;

    final url = _buildUrl(token, courseIds);
    debugPrint('[CourseLiveWS] Connecting');

    _socket = await WebSocket.connect(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );
    debugPrint('[CourseLiveWS] Connected');

    _sub = _socket!.listen(
      _onData,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: false,
    );
  }

  Future<void> disconnect() async {
    _disposed = true;
    await _sub?.cancel();
    _sub = null;
    await _socket?.close(WebSocketStatus.normalClosure);
    _socket = null;
    _items.clear();
  }

  void dispose() {
    disconnect();
    _controller.close();
  }


  void _onData(dynamic raw) {
    if (_disposed) return;
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      final type = json['type'] as String?;
      final data = json['data'];

      switch (type) {
        case 'snapshot':
          _items.clear();
          for (final e in (data as List<dynamic>? ?? [])) {
            final item = CourseLiveItem.fromJson(e as Map<String, dynamic>);
            _items[item.sessionId] = item;
          }
          _emit();

        case 'lobby_opened':
          final item =
              CourseLiveItem.fromJson(data as Map<String, dynamic>);
          _items[item.sessionId] = item;
          _emit();

        case 'lobby_closed':
          final sessionId =
              (data as Map<String, dynamic>)['session_id'] as String?;
          if (sessionId != null) {
            _items.remove(sessionId);
            _emit();
          }
      }
    } catch (e) {
      debugPrint('[CourseLiveWS] parse error: $e');
    }
  }

  void _onDone() {
    debugPrint('[CourseLiveWS] Done');
  }

  void _onError(Object error) {
    debugPrint('[CourseLiveWS] Error: $error');
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_items.values));
    }
  }

  String _buildUrl(String token, List<String> courseIds) {
    final base = ApiConfig.baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://')
        .replaceAll(RegExp(r'/$'), '');
    final ids = courseIds.map(Uri.encodeComponent).join(',');
    return '$base/riddler/v1/courses/live/ws?course_ids=$ids&token=${Uri.encodeComponent(token)}';
  }
}

