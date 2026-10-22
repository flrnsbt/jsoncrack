import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'options.dart';

/// A widget that embeds the JsonCrack JSON viewer in a Flutter mobile/desktop app.
///
/// This widget uses [InAppWebView] to load the JsonCrack HTML application
/// and passes the provided JSON data to it via JavaScript evaluation.
///
/// ### Parameters
///
/// - `json`: The JSON string to display in the viewer.
/// - `url`: The URL or asset path to the JsonCrack HTML file.
///   Default: `'assets/packages/jsoncrack/assets/jsoncrack.html'`.
/// - `brightness`: The theme brightness (`light` or `dark`).
///   If `null`, it defaults to the current theme's brightness.
/// - `options`: Configuration options for the viewer (layoutDirection, etc.).
///   Default: [JsonCrackOptions] with default values.
///
/// ### Example
///
/// ```dart
/// JsonCrackView(
///   json: '{"name": "John", "age": 30}',
///   options: JsonCrackOptions(
///     layoutDirection: 'DOWN',
///   ),
/// )
/// ```
class JsonCrackView extends StatefulWidget {
  /// Creates a [JsonCrackView] widget for mobile/desktop platforms.
  const JsonCrackView({
    super.key,
    required this.json,
    this.url = 'assets/packages/jsoncrack/assets/jsoncrack.html',
    this.brightness,
    this.options = const JsonCrackOptions(),
  });

  /// The JSON string to display in the viewer.
  final String json;

  /// The URL or asset path to the JsonCrack HTML file.
  final String url;

  /// The theme brightness for the viewer.
  ///
  /// If `null`, defaults to the current [Theme] brightness.
  final Brightness? brightness;

  /// Configuration options for the JsonCrack viewer.
  final JsonCrackOptions options;

  @override
  State<JsonCrackView> createState() => _JsonCrackViewState();
}

class _JsonCrackViewState extends State<JsonCrackView> {
  InAppWebViewController? _controller;
  bool _ready = false;

  /// Sends the current JSON data to the web view.
  void _sendToJsonCrack() {
    if (_controller == null || !_ready) return;

    final effectiveBrightness =
        widget.brightness ?? Theme.of(context).brightness;
    final escapedJson = widget.json.replaceAll('"', '\\"').replaceAll('\n', '\\n');
    final source =
        'window.load("$escapedJson", "${effectiveBrightness.name}")';
    _controller!.evaluateJavascript(source: source);
  }

  @override
  void didUpdateWidget(covariant JsonCrackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When JSON or options change, send the updated data to the web view
    if (widget.json != oldWidget.json ||
        widget.options != oldWidget.options ||
        widget.brightness != oldWidget.brightness) {
      _sendToJsonCrack();
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness = widget.brightness ?? Theme.of(context).brightness;
    return InAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      onWebViewCreated: (controller) {
        _controller = controller;
        controller.addWebMessageListener(
          WebMessageListener(
            jsObjectName: '',
            onPostMessage: (message, sourceOrigin, isMainFrame, replyProxy) {
              try {
                final data = jsonDecode(message!.data);
                if (data['status'] == 'ready' || data['type'] == 'ready') {
                  setState(() {
                    _ready = true;
                  });
                  final escapedJson =
                      widget.json.replaceAll('"', '\\"').replaceAll('\n', '\\n');
                  final source =
                      'window.load("$escapedJson", "${effectiveBrightness.name}")';
                  controller.evaluateJavascript(source: source);
                }
              } catch (e) {
                debugPrint('jsoncrack message error: $e');
              }
            },
          ),
        );
      },
    );
  }
}
