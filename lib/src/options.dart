/// Configuration options for the JsonCrack viewer.
///
/// These options control how the embedded JSON viewer behaves and appears.
///
/// - `layoutDirection`: The layout direction of the JSON tree.
///   Values: `'RIGHT'` (default), `'DOWN'`, `'LEFT'`, `'UP'`.
/// - `showGrid`: Whether to show the background grid. Default: `true`.
///
/// Example:
/// ```dart
/// final options = JsonCrackOptions()
///   ..layoutDirection = 'DOWN';
/// ```
class JsonCrackOptions {
  /// Creates a new [JsonCrackOptions] instance with default values.
  const JsonCrackOptions({
    this.layoutDirection = 'RIGHT',
    this.showGrid = true,
    this.extra = const {},
  });

  /// The layout direction of the JSON tree.
  ///
  /// - `'RIGHT'`: Tree grows to the right (default).
  /// - `'DOWN'`: Tree grows downward.
  /// - `'LEFT'`: Tree grows to the left.
  /// - `'UP'`: Tree grows upward.
  final String layoutDirection;

  /// Whether to show the background grid.
  final bool showGrid;

  /// Additional custom options not explicitly defined in this class.
  final Map<String, dynamic> extra;

  /// Converts this options object to a JSON-serializable map.
  ///
  /// The resulting map can be passed to the JsonCrack iframe.
  Map<String, dynamic> toJson() {
    return {
      'layoutDirection': layoutDirection,
      'showGrid': showGrid,
      ...extra,
    };
  }

  /// Creates a copy of this options with the given fields replaced.
  JsonCrackOptions copyWith({
    String? layoutDirection,
    bool? showGrid,
    Map<String, dynamic>? extra,
  }) {
    return JsonCrackOptions(
      layoutDirection: layoutDirection ?? this.layoutDirection,
      showGrid: showGrid ?? this.showGrid,
      extra: extra ?? this.extra,
    );
  }
}
