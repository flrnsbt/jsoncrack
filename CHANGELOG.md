## 0.2.0

- **Type-safe API**: Added `JsonCrackLayoutDirection` enum for compile-time safe layout direction selection.
- **Ready-state callback**: Added `onReady` callback to `JsonCrackView` that fires when the viewer is fully loaded.
- **Custom loading UI**: Added `loadingBuilder` parameter for custom loading indicators.
- **Loading indicators**: Both web and mobile/desktop implementations now show a loading spinner while the viewer initializes.
- **Improved error handling**: Better error handling in message passing between Flutter and the iframe/webview.
- **Brightness change detection**: Web implementation now detects brightness changes and updates the viewer.
- **Proper JSON encoding**: Mobile/desktop implementation now uses `jsonEncode` for safe string escaping.
- **Equality operators**: `JsonCrackOptions` now implements `==` and `hashCode` for proper change detection.
- **Enhanced documentation**: Comprehensive dartdoc comments on all public APIs.
- **Improved example app**:
  - 6 preset JSON samples (added "Array of Objects")
  - Node count display in status bar
  - Viewer ready-state notification via SnackBar
  - Viewer-ready indicator in app bar
  - Enum-based settings dialog
  - Better JSON validation feedback

## 0.1.0

- Initial release of the JsonCrack Flutter package.
- `JsonCrackView` widget for embedding the JsonCrack JSON viewer.
- Support for web (iframe) and mobile/desktop (InAppWebView) platforms.
- Automatic theme detection from the Flutter app's brightness.
- Configurable viewer options via `JsonCrackOptions`:
  - `layoutDirection`: control tree layout direction (`'RIGHT'`, `'DOWN'`, `'LEFT'`, `'UP'`).
  - `showGrid`: toggle the background grid.
- Custom URL support for self-hosted JsonCrack instances.
- Comprehensive documentation and dartdoc comments.
- Example Flutter web project demonstrating all features.
