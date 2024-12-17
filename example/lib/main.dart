import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'my_app.dart';

void main() {
  WebViewPlatform.instance = WebKitWebViewPlatform();
  runApp(const MyApp());
}

