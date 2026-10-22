import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:web/web.dart';
import 'dart:ui_web' as ui_web;

import 'options.dart';

/// A widget that embeds the JsonCrack JSON viewer in a Flutter web app.
///
/// This widget renders an iframe that loads the JsonCrack HTML application
/// and passes the provided JSON data to it via postMessage.
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
  /// Creates a [JsonCrackView] widget.
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
  String? viewType;
  int viewId = 0;

  StreamSubscription? _subscription;

  /// Reference to the iframe element for sending messages.
  HTMLIFrameElement? _iframeElement;

  /// Whether the iframe has signaled it is ready.
  bool _ready = false;

  /// Builds the message payload with current JSON and options.
  dynamic _buildMessage() {
    final effectiveBrightness =
        widget.brightness ?? Theme.of(context).brightness;
    final optionsMap = widget.options.toJson();
    optionsMap['theme'] = effectiveBrightness.name;

    return {
      'type': 'init',
      'data': {
        'json': widget.json,
        'options': optionsMap,
      },
    }.jsify();
  }

  /// Sends the current JSON data to the iframe.
  void _sendToJsonCrack() {
    if (_iframeElement != null && _ready) {
      final message = _buildMessage();
      _iframeElement!.contentWindow!.postMessage(message, '*'.toJS);
    }
  }

  /// Initializes the iframe view factory and sets up message handling.
  void _init() {
    try {
      final viewType = 'jsoncrack_${DateTime.now().millisecondsSinceEpoch}';
      ui_web.platformViewRegistry.registerViewFactory(viewType, (
        int viewId, {
        Object? params,
      }) {
        this.viewId = viewId;
        final element = HTMLIFrameElement()
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.overflow = 'none'
          ..style.border = 'none';

        _iframeElement = element;

        final message = _buildMessage();
        _subscription = window.onMessage.listen((event) {
          final rawData = event.data as JSObject;
          final Map data = rawData.dartify() as Map;
          final type = data['type'];
          if (type == 'ready') {
            element.contentWindow!.postMessage(message, '*'.toJS);

            Future.delayed(const Duration(milliseconds: 200)).then((_) {
              _onReady();
            });
          }
        });

        element.src = widget.url;

        return element..id = '$viewId';
      });
      setState(() {
        this.viewType = viewType;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void didUpdateWidget(covariant JsonCrackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When JSON or options change, send the updated data to the iframe
    if (widget.json != oldWidget.json || widget.options != oldWidget.options) {
      _sendToJsonCrack();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  /// Called when the iframe signals it is ready.
  void _onReady() {
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (viewType == null) {
      return const SizedBox.shrink();
    }
    return Opacity(
      opacity: _ready ? 1 : 0.01,
      child: HtmlElementView(viewType: viewType!),
    );
  }
}
