// ─────────────────────────────────────────────
//  web_stub.dart
//  রাখো: lib/features/payment/web_stub.dart
//
//  Web platform এ webview_flutter নেই।
//  এই stub ফাইল compile error থেকে বাঁচায়।
// ─────────────────────────────────────────────

class WebViewController {
  WebViewController();
  WebViewController setJavaScriptMode(dynamic mode) => this;
  WebViewController setNavigationDelegate(dynamic delegate) => this;
  Future<void> loadRequest(Uri uri) async {}
}

class WebViewWidget {
  final WebViewController controller;
  const WebViewWidget({required this.controller});
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
