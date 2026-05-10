import 'package:flutter/material.dart';

part 'edium_notification_edium_notification_widget.dart';


enum EdiumNotificationType { success, error, info }

class EdiumNotification {
  static void show(
    BuildContext context,
    String message, {
    EdiumNotificationType type = EdiumNotificationType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _EdiumNotificationWidget(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

