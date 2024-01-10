import 'dart:async';
import 'dart:io';

import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter_web_auth_2_platform_interface/flutter_web_auth_2_platform_interface.dart';

class FlutterWebAuth2WindowsPlugin extends FlutterWebAuth2Platform {
  bool authenticated = false;
  Webview? webview;

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
      //Microsofts WebView2 must be installed for this to work
      throw StateError('Webview is not available');
    }
    //Reset
    authenticated = false;
    webview?.close();

    final c = Completer<String>();

    webview = await WebviewWindow.create(
      configuration: CreateConfiguration(
        windowHeight: 720,
        windowWidth: 1280,
        title: 'Authenticate',
        titleBarTopPadding: Platform.isMacOS ? 20 : 0,
      ),
    );
    webview!.addOnUrlRequestCallback((url) {
      final uri = Uri.parse(url);
      if (uri.scheme == callbackUrlScheme) {
        authenticated = true;
        c.complete(url);
        webview?.close();
      }
    });
    webview!.launch(url);
    return c.future;
  }
}
