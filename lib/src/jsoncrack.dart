import 'package:flutter/material.dart';
import 'web.dart' if (dart.library.io) 'io.dart' as src;
import 'options.dart';

/// A widget that embeds the JsonCrack JSON viewer in your Flutter app.
///
/// This is the main entry point for using JsonCrack. It automatically selects
/// the appropriate platform implementation:
/// - **Web**: Uses an iframe with `postMessage` communication.
/// - **Mobile/Desktop**: Uses [WebViewWidget] (via `webview_all`) for native rendering.
///
/// ## Features
///
/// - Interactive graph-based JSON visualization
/// - Light and dark theme support
/// - Configurable layout direction via [JsonCrackLayoutDirection]
/// - Grid overlay toggle
/// - Built-in camera controls toggle
/// - Auto-center on layout changes
/// - Configurable max renderable nodes limit
/// - Ready-state callback via [onReady]
/// - Custom loading UI via [loadingBuilder]
///
/// ## Quick Start
///
/// ```dart
/// JsonCrackView(
///   json: '{"name": "Alice", "age": 25}',
/// )
/// ```
///
/// ## With Options
///
/// ```dart
/// JsonCrackView(
///   json: '{"key": "value"}',
///   brightness: Brightness.dark,
///   options: JsonCrackOptions(
///     layoutDirection: JsonCrackLayoutDirection.down,
///     showGrid: false,
///     showControls: true,
///     maxRenderableNodes: 500,
///   ),
///   onReady: () => print('Viewer ready!'),
/// )
/// ```
///
/// ## With Custom Loading UI
///
/// ```dart
/// JsonCrackView(
///   json: '{"key": "value"}',
///   loadingBuilder: (context, progress) {
///     return const Center(child: CircularProgressIndicator());
///   },
/// )
/// ```
class JsonCrackView extends StatelessWidget {
  /// Creates a [JsonCrackView] widget.
  ///
  /// [json] is required and must be a valid JSON string.
  /// [url] defaults to the bundled JsonCrack HTML asset.
  /// [brightness] defaults to the current theme's brightness.
  /// [options] controls viewer behavior (layout, grid, controls, etc.).
  /// [onReady] is called when the viewer finishes loading.
  /// [loadingBuilder] provides a custom loading indicator.
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
  ///
  /// Must be a valid JSON string. The viewer will attempt to render
  /// whatever is provided, but invalid JSON may cause errors.
  final String json;

  /// The URL to the JsonCrack widget HTML page.
  ///
  /// By default, the widget loads from the hosted Cloudflare CDN:
  /// `https://jsoncrack-bdf.pages.dev/cdn/`.
  ///
  /// To embed your own self-hosted or offline instance, use the compiled
  /// `jsoncrack-react/` bundle and provide its URL or path here:
  /// ```dart
  /// JsonCrackView(
  ///   json: '{"key": "value"}',
  ///   url: 'https://your-domain.com/cdn/',
  /// )
  /// ```
  final String? url;

  /// The theme brightness for the viewer.
  ///
  /// If `null`, defaults to the current [Theme] brightness via
  /// [Theme.of(context).brightness].
  final Brightness? brightness;

  /// Configuration options for the JsonCrack viewer.
  ///
  /// Controls layout direction, grid visibility, and other viewer settings.
  /// See [JsonCrackOptions] for available options.
  final JsonCrackOptions options;

  /// Called when the viewer finishes loading and is ready to display data.
  ///
  /// Use this callback to know when the viewer is fully initialized
  /// and has received the initial JSON data.
  final VoidCallback? onReady;

  /// Builder for a custom loading indicator.
  ///
  /// [progress] indicates the loading progress (0.0 to 1.0).
  /// When `null`, a default circular progress indicator is shown.
  ///
  /// If this callback is `null`, no loading indicator is shown.
  final Widget Function(BuildContext context, double progress)? loadingBuilder;

  @override
  Widget build(BuildContext context) {
    return src.JsonCrackView(
      json: json,
      brightness: brightness,
      url: url,
      options: options,
      onReady: onReady,
      loadingBuilder: loadingBuilder,
    );
  }
}
