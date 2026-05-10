import 'package:edium/core/theme/app_colors.dart';
import 'package:edium/core/theme/app_dimens.dart';
import 'package:edium/core/theme/app_text_styles.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

Widget _embeddedLegalWebView(WebViewController controller) {
  final gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
    Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
  };

  PlatformWebViewWidgetCreationParams params =
      PlatformWebViewWidgetCreationParams(
    controller: controller.platform,
    layoutDirection: TextDirection.ltr,
    gestureRecognizers: gestureRecognizers,
  );

  if (WebViewPlatform.instance is WebKitWebViewPlatform) {
    params = WebKitWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
      params,
    );
  } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
    params =
        AndroidWebViewWidgetCreationParams.fromPlatformWebViewWidgetCreationParams(
      params,
      displayWithHybridComposition: true,
    );
  }

  return WebViewWidget.fromPlatformCreationParams(params: params);
}


class LegalDocumentScreen extends StatefulWidget {
  final String url;
  final String title;

  const LegalDocumentScreen({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.url);
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    if (uri != null && uri.hasScheme) {
      _controller.loadRequest(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(widget.url);
    final invalid = uri == null || !uri.hasScheme;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    size: 20, color: AppColors.mono900),
                onPressed: () => context.pop(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.screenPaddingH),
              child: Text(widget.title, style: AppTextStyles.screenTitle),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: invalid
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.screenPaddingH),
                        child: Text(
                          'Не удалось открыть страницу',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.mono400),
                        ),
                      ),
                    )
                  : _embeddedLegalWebView(_controller),
            ),
          ],
        ),
      ),
    );
  }
}
