import 'package:flutter/material.dart';

class NavigationLogger extends NavigatorObserver {
  String? _current;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final to = route.settings.name;
    if (to == null) return;
    _log(_current, to);
    _current = to;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final to = previousRoute?.settings.name;
    if (to == null) return;
    _log(route.settings.name, to);
    _current = to;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final to = newRoute?.settings.name;
    if (to == null) return;
    _log(oldRoute?.settings.name, to);
    _current = to;
  }

  void _log(String? from, String to) {
    debugPrint('[Nav] ${from ?? '?'} -> $to');
  }
}
