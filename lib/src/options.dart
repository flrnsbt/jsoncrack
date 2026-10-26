/// Configuration options for the JsonCrack viewer.
///
/// These options control how the embedded JSON viewer behaves and appears.
///
/// ## Options
///
/// - [layoutDirection]: The layout direction of the JSON tree.
/// - [showGrid]: Whether to show the background grid.
/// - [showControls]: Whether to show built-in camera controls (pan/zoom).
/// - [centerOnLayout]: Auto-center on first/major layout changes.
/// - [maxRenderableNodes]: Node rendering safety limit.
/// - [extra]: Additional custom options passed through to the viewer.
///
/// ## Example
///
/// ```dart
/// final options = JsonCrackOptions(
///   layoutDirection: JsonCrackLayoutDirection.down,
///   showGrid: false,
///   showControls: true,
/// );
/// ```
///
/// You can also use the legacy string-based API:
/// ```dart
/// final options = JsonCrackOptions(layoutDirection: 'DOWN');
/// ```
class JsonCrackOptions {
  /// Creates a new [JsonCrackOptions] instance with default values.
  ///
  /// [layoutDirection] accepts either a [JsonCrackLayoutDirection] value
  /// or a string (`'RIGHT'`, `'DOWN'`, `'LEFT'`, `'UP'`).
  const JsonCrackOptions({
    this.layoutDirection = JsonCrackLayoutDirection.right,
    this.showGrid = true,
    this.showControls = false,
    this.centerOnLayout = true,
    this.maxRenderableNodes = 1500,
    this.extra = const {},
  });

  /// The layout direction of the JSON tree.
  ///
  /// Use [JsonCrackLayoutDirection] for type-safe values:
  /// - [JsonCrackLayoutDirection.right]: Tree grows to the right (default).
  /// - [JsonCrackLayoutDirection.down]: Tree grows downward.
  /// - [JsonCrackLayoutDirection.left]: Tree grows to the left.
  /// - [JsonCrackLayoutDirection.up]: Tree grows upward.
  ///
  /// For backward compatibility, a raw string value is also accepted.
  final Object layoutDirection;

  /// Whether to show the background grid.
  /// Default: `true`.
  final bool showGrid;

  /// Whether to show built-in camera controls (pan/zoom buttons).
  /// Default: `false`.
  final bool showControls;

  /// Auto-center the view on first and major layout changes.
  /// Default: `true`.
  final bool centerOnLayout;

  /// Maximum number of nodes that can be rendered before showing a fallback.
  /// For large inputs, rendering cost grows with the number of nodes.
  /// Recommended range: up to ~300–500 nodes for smooth interaction.
  /// Default: `1500`.
  final int maxRenderableNodes;

  /// Additional custom options not explicitly defined in this class.
  ///
  /// These are passed through to the underlying viewer and may include
  /// future options not yet exposed by this package.
  final Map<String, dynamic> extra;

  /// Returns the layout direction as a string for serialization.
  String get _layoutDirectionString {
    if (layoutDirection is JsonCrackLayoutDirection) {
      return (layoutDirection as JsonCrackLayoutDirection).name.toUpperCase();
    }
    return layoutDirection.toString();
  }

  /// Converts this options object to a JSON-serializable map.
  ///
  /// The resulting map can be passed to the JsonCrack iframe.
  Map<String, dynamic> toJson() {
    return {
      'layoutDirection': _layoutDirectionString,
      'showGrid': showGrid,
      'showControls': showControls,
      'centerOnLayout': centerOnLayout,
      'maxRenderableNodes': maxRenderableNodes,
      ...extra,
    };
  }

  /// Creates a copy of this options with the given fields replaced.
  JsonCrackOptions copyWith({
    Object? layoutDirection,
    bool? showGrid,
    bool? showControls,
    bool? centerOnLayout,
    int? maxRenderableNodes,
    Map<String, dynamic>? extra,
  }) {
    return JsonCrackOptions(
      layoutDirection: layoutDirection ?? this.layoutDirection,
      showGrid: showGrid ?? this.showGrid,
      showControls: showControls ?? this.showControls,
      centerOnLayout: centerOnLayout ?? this.centerOnLayout,
      maxRenderableNodes: maxRenderableNodes ?? this.maxRenderableNodes,
      extra: extra ?? this.extra,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is JsonCrackOptions &&
        other._layoutDirectionString == _layoutDirectionString &&
        other.showGrid == showGrid &&
        other.showControls == showControls &&
        other.centerOnLayout == centerOnLayout &&
        other.maxRenderableNodes == maxRenderableNodes &&
        mapEquals(other.extra, extra);
  }

  @override
  int get hashCode {
    return Object.hash(
      _layoutDirectionString,
      showGrid,
      showControls,
      centerOnLayout,
      maxRenderableNodes,
      Object.hashAll(extra.entries),
    );
  }

  @override
  String toString() =>
      'JsonCrackOptions(layoutDirection: $_layoutDirectionString, showGrid: $showGrid, '
      'showControls: $showControls, '
      'centerOnLayout: $centerOnLayout, maxRenderableNodes: $maxRenderableNodes)';
}

/// The layout direction for the JSON tree visualization.
///
/// Controls how the tree nodes are arranged relative to their parent:
/// - [right]: Nodes grow to the right of their parent (default).
/// - [down]: Nodes grow below their parent.
/// - [left]: Nodes grow to the left of their parent.
/// - [up]: Nodes grow above their parent.
enum JsonCrackLayoutDirection {
  /// Tree grows to the right.
  right,

  /// Tree grows downward.
  down,

  /// Tree grows to the left.
  left,

  /// Tree grows upward.
  up,
}

/// Helper for comparing maps in [JsonCrackOptions.==].
bool mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
