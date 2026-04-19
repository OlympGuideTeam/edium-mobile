import 'package:flutter/foundation.dart';

class DeepLinkService extends ChangeNotifier {
  String? _pendingRoute;

  String? get pendingRoute => _pendingRoute;

  void setPendingRoute(String route) {
    _pendingRoute = route;
    notifyListeners();
  }

  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }
}
