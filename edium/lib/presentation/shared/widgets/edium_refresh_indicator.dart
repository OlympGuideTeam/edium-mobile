import 'package:flutter/material.dart';

/// Кастомный pull-to-refresh спиннер в стиле Edium (чёрно-белый минимализм).
class EdiumRefreshIndicator extends StatelessWidget {
  final Widget child;
  final RefreshCallback onRefresh;

  const EdiumRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFF1A1A1A),
      backgroundColor: Colors.white,
      strokeWidth: 2.0,
      elevation: 0,
      displacement: 44,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }
}
