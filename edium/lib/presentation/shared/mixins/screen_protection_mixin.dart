import 'dart:ui';

import 'package:edium/core/di/injection.dart';
import 'package:edium/services/screen_protection/screen_protection_service.dart';
import 'package:flutter/material.dart';

mixin ScreenProtectionMixin<T extends StatefulWidget> on State<T>, WidgetsBindingObserver {
  OverlayEntry? _blurOverlay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    getIt<ScreenProtectionService>().enableProtection();
  }

  @override
  void dispose() {
    _removeBlurOverlay();
    WidgetsBinding.instance.removeObserver(this);
    getIt<ScreenProtectionService>().disableProtection();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _showBlurOverlay();
    } else if (state == AppLifecycleState.resumed) {
      _removeBlurOverlay();
    }
  }

  void _showBlurOverlay() {
    if (_blurOverlay != null) return;
    _blurOverlay = OverlayEntry(
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
        child: const ColoredBox(
          color: Color(0xCC000000),
          child: SizedBox.expand(),
        ),
      ),
    );
    Overlay.of(context).insert(_blurOverlay!);
  }

  void _removeBlurOverlay() {
    _blurOverlay?.remove();
    _blurOverlay = null;
  }
}
