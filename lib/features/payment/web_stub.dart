import 'package:flutter/widgets.dart';

class WebViewController {
  WebViewController();
  WebViewController setJavaScriptMode(dynamic mode) => this;
  WebViewController setNavigationDelegate(dynamic delegate) => this;
  Future<void> loadRequest(Uri uri) async {}
}

class WebViewWidget extends StatelessWidget {
  final WebViewController controller;
  const WebViewWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class JavaScriptMode {
  static const unrestricted = JavaScriptMode._();
  const JavaScriptMode._();
}

class NavigationDelegate {
  const NavigationDelegate({
    dynamic onPageStarted,
    dynamic onPageFinished,
    dynamic onProgress,
    dynamic onNavigationRequest,
  });
}

class NavigationRequest {
  final String url;
  const NavigationRequest({required this.url});
}

class NavigationDecision {
  static const prevent = NavigationDecision._();
  static const navigate = NavigationDecision._();
  const NavigationDecision._();
}
