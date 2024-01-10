import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';

class FlutterWebAuth2WindowsPlugin extends FlutterWebAuth2Platform {
  static void registerWith() {
    FlutterWebAuth2Platform.instance = FlutterWebAuth2WindowsPlugin();
  }

  @override
  Future<String> authenticate({
    required String url,
    required String callbackUrlScheme,
    required Map<String, dynamic> options,
  }) async {
    if (!await WebviewWindow.isWebviewAvailable()) {
      throw StateError('Webview is not available');
    }
    final c = Completer<String>();
    final webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        windowHeight: 720,
        windowWidth: 1280,
        title: 'easyroam authentication',
        titleBarTopPadding: Platform.isMacOS ? 20 : 0,
      ),
    );
    webview.addOnUrlRequestCallback((url) {
      final uri = Uri.parse(url);
      if (uri.scheme == callbackUrlScheme) {
        c.complete(url);
        webview.close();
      }
    });
    webview.launch(url);
    return c.future;
  }
}
