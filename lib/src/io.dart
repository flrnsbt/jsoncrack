import 'dart:convert';

import 'package:flutter/material.dart' as material;
import 'package:material_ui/material_ui.dart';
import 'package:jsoncrack/src/config.dart';
import 'package:webview_all/webview_all.dart';

import 'options.dart';

/// The JavaScript channel name used to receive messages from the WebView.
const _kChannelName = 'JsonCrackBridge';

/// A widget that embeds the JsonCrack JSON viewer in a Flutter mobile/desktop app.
///
/// This widget uses [WebViewWidget] (via the `webview_all` package) to load the
/// JsonCrack HTML application and passes the provided JSON data to it via
/// JavaScript evaluation.
///
/// ### Parameters
///
/// - `json`: The JSON string to display in the viewer.
/// - `url`: The URL to the JsonCrack widget HTML page.
///   Defaults to the hosted CDN: `https://jsoncrack-bdf.pages.dev/cdn/`.
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
    this.url,
    this.brightness,
    this.options = const JsonCrackOptions(),
    this.onReady,
    this.loadingBuilder,
  });

  /// The JSON string to display in the viewer.
  final String json;

  /// The URL to the JsonCrack widget HTML page. Defaults to hosted CDN.
  final String? url;

  /// The theme brightness for the viewer.
  ///
  /// If `null`, defaults to the current [Theme] brightness.
  final Brightness? brightness;

  /// Configuration options for the JsonCrack viewer.
  final JsonCrackOptions options;

  /// Called when the viewer finishes loading and is ready to display data.
  final VoidCallback? onReady;

  /// Builder for a custom loading indicator.
  final Widget Function(BuildContext context, double progress)? loadingBuilder;

  @override
  State<JsonCrackView> createState() => _JsonCrackViewState();
}

class _JsonCrackViewState extends State<JsonCrackView> {
  late final WebViewController _controller;
  bool _ready = false;

  /// Sends the current JSON data to the web view.
  Future<void> _sendToJsonCrack() async {
    if (!_ready) return;

    final effectiveBrightness =
        widget.brightness ??
        Theme.maybeBrightnessOf(context) ??
        material.Theme.maybeBrightnessOf(context) ??
        Brightness.light;
    final optionsMap = widget.options.toJson();
    optionsMap['theme'] = effectiveBrightness.name;

    // Use JSON encoding for safe string escaping
    final payload = jsonEncode({
      'type': 'init',
      'data': {'json': widget.json, 'options': optionsMap},
    });

    try {
      await _controller.runJavaScript('''
        if (window.loadJsonCrack) {
          window.loadJsonCrack($payload);
        } else {
          window.dispatchEvent(new MessageEvent('message', {
            data: $payload
          }));
        }
      ''');
    } catch (e) {
      debugPrint('jsoncrack send error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        _kChannelName,
        onMessageReceived: (JavaScriptMessage message) {
          try {
            final data = jsonDecode(message.message);
            if (data is Map &&
                (data['status'] == 'ready' || data['type'] == 'ready')) {
              if (mounted) {
                final wasReady = _ready;
                setState(() {
                  _ready = true;
                });
                if (!wasReady) {
                  widget.onReady?.call();
                }
                _sendToJsonCrack();
              }
            }
          } catch (e) {
            debugPrint('jsoncrack message error: $e');
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) async {
            if (widget.url != null) {
              await _controller.runJavaScript(
                'if (window.setIframeSrc) window.setIframeSrc(${jsonEncode(widget.url)});',
              );
            }
          },
        ),
      )
      ..loadFlutterAsset(jsoncrackBridgeAsset);
  }

  @override
  void didUpdateWidget(covariant JsonCrackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url && widget.url != null) {
      _controller.runJavaScript(
        'if (window.setIframeSrc) window.setIframeSrc(${jsonEncode(widget.url)});',
      );
    }
    // When JSON or options change, send the updated data to the web view
    if (widget.json != oldWidget.json ||
        widget.options != oldWidget.options ||
        widget.brightness != oldWidget.brightness) {
      _sendToJsonCrack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (!_ready)
          widget.loadingBuilder != null
              ? widget.loadingBuilder!(context, 0.5)
              : const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading JSON viewer...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
      ],
    );
  }
}
