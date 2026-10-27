import 'dart:async';
import 'dart:js_interop';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:jsoncrack/src/config.dart';
import 'package:web/web.dart' hide Text, Element;
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
  /// Creates a [JsonCrackView] widget for web platforms.
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
  static const String viewType = 'jsoncrack';
  int viewId = 0;

  StreamSubscription? _subscription;
  Listenable? _geometryListenable;

  /// Reference to the iframe element for sending messages.
  HTMLIFrameElement? _iframeElement;

  /// Whether the iframe has signaled it is ready.
  bool _ready = false;

  /// Whether the initial data has been sent to the iframe.
  bool _dataSent = false;

  /// Builds the message payload with current JSON and options.
  dynamic _buildMessage() {
    final effectiveBrightness =
        widget.brightness ??
        Theme.maybeBrightnessOf(context) ??
        material.Theme.maybeBrightnessOf(context) ??
        Brightness.light;
    final optionsMap = widget.options.toJson();
    optionsMap['theme'] = effectiveBrightness.name;

    return {
      'type': 'init',
      'data': {'json': widget.json, 'options': optionsMap},
    }.jsify();
  }

  /// Sends the current JSON data to the iframe.
  void _sendToJsonCrack() {
    if (_iframeElement != null) {
      final message = _buildMessage();
      _iframeElement!.contentWindow!.postMessage(message, '*'.toJS);
    }
  }

  bool? _viewRegistered;

  /// Initializes the iframe view factory and sets up message handling.
  void _init() {
    try {
      _viewRegistered ??= ui_web.platformViewRegistry.registerViewFactory(
        viewType,
        (int viewId, {Object? params}) {
          final element = HTMLIFrameElement()
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.overflow = 'hidden'
            ..style.border = 'none';

          String src = 'assets/$jsoncrackBridgeAsset';
          if (widget.url != null) {
            src += '?src=${Uri.encodeComponent(widget.url!)}';
          }
          element.src = src;

          return element;
        },
      );
    } catch (e) {
      debugPrint('jsoncrack init error: $e');
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  bool _routeVisible = true;
  _ScaffoldData? _nearestScaffold;

  bool get isDrawerOpened {
    return _nearestScaffold?.isDrawerOpen ?? false;
  }

  @override
  void didChangeDependencies() {
    _routeVisible = ModalRoute.isCurrentOf(context) ?? false;
    _nearestScaffold?.removeGeometryChangesListener(_isVisible);
    _nearestScaffold = null;
    if (_routeVisible) {
      _nearestScaffold = context.localScaffold;
      if (_nearestScaffold != null) {
        _nearestScaffold!.addGeometryChangesListener(_isVisible);
      }
    }
    _isVisible();

    super.didChangeDependencies();
  }

  void _isVisible() {
    final bool visible = _routeVisible && !isDrawerOpened;
    _iframeElement?.style.pointerEvents = visible ? 'auto' : 'none';
  }

  @override
  void didUpdateWidget(covariant JsonCrackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url && _iframeElement != null) {
      String src = 'assets/$jsoncrackBridgeAsset';
      if (widget.url != null) {
        src += '?src=${Uri.encodeComponent(widget.url!)}';
      }
      _iframeElement!.src = src;
    }
    // When JSON or options change, send the updated data to the iframe
    if (widget.json != oldWidget.json ||
        widget.options != oldWidget.options ||
        widget.brightness != oldWidget.brightness) {
      _sendToJsonCrack();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _geometryListenable?.removeListener(_isVisible);
    super.dispose();
  }

  /// Called when the iframe signals it is ready.
  void _onReady() {
    if (mounted) {
      setState(() {
        _ready = true;
      });
      widget.onReady?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while iframe is loading
    final loadingWidget = widget.loadingBuilder != null
        ? widget.loadingBuilder!(context, 0.5)
        : Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                _textWidget('Loading JSON viewer...', color: Colors.grey),
              ],
            ),
          );
    return Stack(
      children: [
        // Keep iframe in background with minimal opacity
        Opacity(
          opacity: _ready ? 1 : 0.01,
          child: HtmlElementView(
            viewType: viewType,
            onPlatformViewCreated: (id) {
              viewId = id;
              final element = _iframeElement =
                  ui_web.platformViewRegistry.getViewById(viewId)
                      as HTMLIFrameElement;
              _subscription = window.onMessage.listen((event) {
                try {
                  final data = event.data?.dartify();
                  if (data is Map && data['type'] == 'ready' && !_dataSent) {
                    _dataSent = true;
                    final message = _buildMessage();
                    if (element.contentWindow != null) {
                      element.contentWindow!.postMessage(message, '*'.toJS);
                      Future.delayed(const Duration(milliseconds: 200)).then((
                        _,
                      ) {
                        _onReady();
                      });
                    }
                  }
                } catch (e) {
                  debugPrint('jsoncrack message error: $e');
                }
              });
            },
          ),
        ),

        if (!_ready) loadingWidget,
      ],
    );
  }
}

// Helper to avoid ambiguity with package:web's Text
Widget _textWidget(String data, {double fontSize = 14, Color? color}) {
  return Text(
    data,
    style: TextStyle(fontSize: fontSize, color: color),
  );
}

extension on BuildContext {
  _ScaffoldData? get localScaffold {
    ScaffoldState? targetScaffold;
    material.ScaffoldState? targetMaterialScaffold;
    final children = <Element>[];
    visitAncestorElements((Element element) {
      final widget = element.widget;
      if (widget is Scaffold) {
        targetScaffold = (element as StatefulElement).state as ScaffoldState;

        return false;
      } else if (widget is material.Scaffold) {
        targetMaterialScaffold =
            (element as material.StatefulElement).state
                as material.ScaffoldState;
        return false;
      }

      if (widget is DrawerController || widget is material.DrawerController) {
        return false;
      }

      children.add(element);
      if (children.length > 2) {
        children.removeAt(0);
      }

      return true;
    });

    if (targetScaffold != null) {
      return _MaterialUIScaffoldData(targetScaffold!, children[0]);
    } else if (targetMaterialScaffold != null) {
      return _MaterialScaffoldData(targetMaterialScaffold!, children[0]);
    }

    return null;
  }
}

abstract class _ScaffoldData {
  const _ScaffoldData();

  bool get isDrawerOpen;

  void addGeometryChangesListener(void Function() listener);
  void removeGeometryChangesListener(void Function() listener);
}

class _MaterialUIScaffoldData extends _ScaffoldData {
  final ScaffoldState _state;
  final Element _context;
  const _MaterialUIScaffoldData(this._state, this._context);

  @override
  bool get isDrawerOpen {
    return _state.isDrawerOpen || _state.isEndDrawerOpen;
  }

  ValueListenable<ScaffoldGeometry> get _geometry =>
      Scaffold.geometryOf(_context);

  @override
  void addGeometryChangesListener(void Function() listener) {
    _geometry.addListener(listener);
  }

  @override
  void removeGeometryChangesListener(void Function() listener) {
    _geometry.removeListener(listener);
  }
}

class _MaterialScaffoldData extends _ScaffoldData {
  final material.ScaffoldState _state;
  final Element _context;
  const _MaterialScaffoldData(this._state, this._context);

  @override
  bool get isDrawerOpen {
    return _state.isDrawerOpen || _state.isEndDrawerOpen;
  }

  ValueListenable<material.ScaffoldGeometry> get _geometry =>
      material.Scaffold.geometryOf(_context);

  @override
  void addGeometryChangesListener(void Function() listener) {
    _geometry.addListener(listener);
  }

  @override
  void removeGeometryChangesListener(void Function() listener) {
    _geometry.removeListener(listener);
  }
}
