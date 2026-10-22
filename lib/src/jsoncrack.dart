import 'package:flutter/material.dart';
import 'web.dart' if (dart.library.io) 'io.dart' as src;
import 'options.dart';

/// A widget that embeds the JsonCrack JSON viewer in your Flutter app.
///
/// This is the main entry point for using JsonCrack. It automatically selects
/// the appropriate platform implementation (web or mobile/desktop).
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
class JsonCrackView extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return src.JsonCrackView(
      json: json,
      brightness: brightness,
      url: url,
      options: options,
    );
  }
}
