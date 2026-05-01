import 'package:flutter/foundation.dart';

class DeepLinkService extends ChangeNotifier {
  String? _pendingRoute;
  String? _pendingRole;

  String? get pendingRoute => _pendingRoute;

  void setPendingRoute(String route, {String? role}) {
    debugPrint('[DeepLinkService] setPendingRoute: $route (prev: $_pendingRoute), role: $role');
    _pendingRoute = route;
    _pendingRole = role;
    notifyListeners();
  }

  String? consumePendingRoute() {
    final route = _pendingRoute;
    _pendingRoute = null;
    debugPrint('[DeepLinkService] consumePendingRoute: $route');
    return route;
  }

  String? consumePendingRole() {
    final role = _pendingRole;
    _pendingRole = null;
    return role;
  }
}
