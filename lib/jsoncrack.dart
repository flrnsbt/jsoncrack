/// A Flutter package that embeds the [JsonCrack](https://jsoncrack.com) JSON viewer
/// as a widget in your Flutter application.
///
/// JsonCrack provides an interactive, visual way to explore and edit JSON data
/// using a graph-based tree view.
///
/// ## Features
///
/// - Visual JSON tree viewer with graph layout
/// - Support for light and dark themes
/// - Configurable layout direction (right/down/left/up)
/// - Works on web, mobile, and desktop platforms
///
/// ## Quick start
///
/// Add `jsoncrack` to your `pubspec.yaml`:
///
/// ```yaml
/// dependencies:
///   jsoncrack: ^0.1.0
/// ```
///
/// Then use it in your app:
///
/// ```dart
/// import 'package:jsoncrack/jsoncrack.dart';
///
/// JsonCrackView(
///   json: '{"name": "Alice", "age": 25}',
/// )
/// ```
///
/// ## Customization
///
/// ```dart
/// JsonCrackView(
///   json: '{"key": "value"}',
///   brightness: Brightness.dark,
///   options: JsonCrackOptions(
///     layoutDirection: 'DOWN',
///   ),
/// )
/// ```
///
library;

export 'src/jsoncrack.dart';
export 'src/options.dart';
