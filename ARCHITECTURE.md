# Architecture

This document describes the technical architecture of the jsoncrack Flutter package.

## Overview

The jsoncrack package embeds the [JsonCrack](https://jsoncrack.com) JSON viewer widget into Flutter applications. It uses a platform-specific approach to render the visualization:

- **Web**: Uses an iframe with `postMessage` communication
- **Mobile/Desktop**: Uses `WebViewWidget` (via `webview_all`) with JavaScript evaluation

The widget automatically selects the correct implementation at compile time using Dart's conditional imports.

## Package Structure

```
lib/
├── jsoncrack.dart          # Main package export
└── src/
    ├── config.dart         # Configuration constants (CDN URL, asset paths)
    ├── options.dart        # JsonCrackOptions and JsonCrackLayoutDirection
    ├── jsoncrack.dart      # Public JsonCrackView widget (platform-agnostic)
    ├── web.dart            # Web platform implementation
    └── io.dart             # Mobile/Desktop implementation
```

## Core Components

### 1. Main Export (`lib/jsoncrack.dart`)

The main entry point that exports the public API:

```dart
export 'src/jsoncrack.dart';
export 'src/options.dart' show JsonCrackOptions, JsonCrackLayoutDirection;
```

### 2. Public Widget (`lib/src/jsoncrack.dart`)

The `JsonCrackView` class is the public-facing widget that users interact with. It:

- Accepts all user-facing parameters (json, url, brightness, options, callbacks)
- Uses conditional imports to delegate to platform-specific implementations
- Provides a unified API regardless of the target platform

```dart
import 'web.dart' if (dart.library.io) 'io.dart' as src;

class JsonCrackView extends StatelessWidget {
  // ... parameters
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
```

### 3. Configuration (`lib/src/config.dart`)

Defines constants used across the package:

- `jsoncrackHTMLURL`: Default CDN URL for the hosted widget
- `jsoncrackBridgeAsset`: Path to the local bridge HTML asset bundled with the package

### 4. Options (`lib/src/options.dart`)

Contains configuration classes:

#### JsonCrackOptions

Configuration options for the viewer:

- `layoutDirection`: Tree layout direction (enum or string for backward compatibility)
- `showGrid`: Background grid visibility
- `showControls`: Built-in camera controls
- `centerOnLayout`: Auto-center on layout changes
- `maxRenderableNodes`: Rendering performance limit
- `extra`: Additional custom options for forward compatibility

The class includes:

- `toJson()`: Converts options to a JSON-serializable map
- `copyWith()`: Creates modified copies
- `==` and `hashCode`: For equality comparison
- `toString()`: For debugging

#### JsonCrackLayoutDirection

Type-safe enum for layout directions:

```dart
enum JsonCrackLayoutDirection {
  right,  // Default
  down,
  left,
  up,
}
```

## Platform Implementations

### Web Implementation (`lib/src/web.dart`)

The web implementation uses an iframe to embed the JsonCrack widget.

#### Key Components

**_JsonCrackViewState**: Manages the iframe lifecycle and communication.

**View Registration**: Uses `ui_web.platformViewRegistry.registerViewFactory` to register the iframe as a Flutter platform view.

**Message Communication**:

1. The iframe loads the bridge HTML asset: `assets/packages/jsoncrack/assets/jsoncrack.html`
2. If a custom URL is provided, it's passed as a query parameter: `?src=<encoded-url>`
3. The bridge HTML then loads the actual JsonCrack widget from the URL
4. When the widget is ready, it sends a `postMessage` with type `ready`
5. The Flutter app responds with the JSON data and options via `postMessage`

**Scaffold Integration**: Includes logic to detect when a Drawer is open and disable iframe pointer events to prevent conflicts.

**Lifecycle**:

```dart
initState() → _init() → registerViewFactory
build() → HtmlElementView → iframe created
onMessage('ready') → _sendToJsonCrack() → data sent
didUpdateWidget() → detect changes → resend data
dispose() → cleanup subscriptions
```

### Mobile/Desktop Implementation (`lib/src/io.dart`)

The mobile/desktop implementation uses `WebViewWidget` from the `webview_all` package.

#### Key Components

**_JsonCrackViewState**: Manages the WebView lifecycle and communication.

**JavaScript Channel**: Uses a named JavaScript channel (`JsonCrackBridge`) to receive messages from the WebView.

**Message Communication**:

1. The WebView loads the bridge HTML asset via `loadFlutterAsset()`
2. JavaScript in the bridge sends messages via the channel when ready
3. Flutter responds by evaluating JavaScript to send JSON data and options
4. If a custom URL is provided, it's set via `setIframeSrc()` JavaScript function

**Data Transmission**:

```dart
_sendToJsonCrack() → jsonEncode(payload) → runJavaScript()
```

The payload is JSON-encoded to ensure safe string escaping before being passed to JavaScript.

**Lifecycle**:

```dart
initState() → WebViewController setup → addJavaScriptChannel → loadFlutterAsset
onPageFinished → setIframeSrc if custom URL
onMessage('ready') → _sendToJsonCrack() → data sent
didUpdateWidget() → detect changes → resend data
```

## Communication Protocol

### Message Format

Both implementations use a consistent message format:

```dart
{
  'type': 'init',
  'data': {
    'json': '<json string>',
    'options': {
      'layoutDirection': 'RIGHT',
      'showGrid': true,
      'showControls': false,
      'centerOnLayout': true,
      'maxRenderableNodes': 1500,
      'theme': 'light',  // or 'dark'
    }
  }
}
```

### Ready Signal

The widget signals readiness via:

- **Web**: `postMessage` with `{ type: 'ready' }`
- **Mobile/Desktop**: JavaScript channel message with `{ status: 'ready' }` or `{ type: 'ready' }`

### Dynamic Updates

When parameters change (json, options, brightness), the widget:

1. Detects the change in `didUpdateWidget()`
2. Rebuilds the message payload with current values
3. Sends the new data to the iframe/WebView
4. The JsonCrack widget updates its visualization

## Asset Management

### Bridge HTML

The package includes a bridge HTML file (`assets/jsoncrack.html`) that:

1. Loads the actual JsonCrack widget from the CDN or custom URL
2. Handles communication between Flutter and the widget
3. Manages iframe creation and message passing

### CDN Hosting

By default, the widget loads from the hosted CDN:

```
https://jsoncrack-bdf.pages.dev/cdn/
```

This allows the package to work without requiring users to build or host the widget themselves.

### Self-Hosting

Users can self-host the widget by:

1. Building the React widget in `jsoncrack-react/`
2. Hosting the built files on their own server
3. Passing the custom URL to `JsonCrackView`

## Performance Considerations

### Node Rendering Limit

The `maxRenderableNodes` option limits the number of nodes rendered to prevent performance issues with large JSON payloads:

- Default: 1500 nodes
- Recommended: 300-500 nodes for smooth interaction
- Fallback behavior when limit exceeded

### Loading States

Both implementations show a loading indicator until the widget signals readiness:

- Default: CircularProgressIndicator with "Loading JSON viewer..." text
- Custom: Users can provide a `loadingBuilder` for custom loading UI

### Theme Adaptation

The widget automatically adapts to the app's theme:

- If `brightness` is null, uses `Theme.of(context).brightness`
- Theme is passed to the widget and applied immediately
- Dynamic theme changes trigger updates via `didUpdateWidget()`

## Conditional Imports

The package uses Dart's conditional imports to select the platform implementation:

```dart
import 'web.dart' if (dart.library.io) 'io.dart' as src;
```

- `dart.library.io` is available on mobile/desktop platforms
- On web, it's not available, so `web.dart` is imported
- This selection happens at compile time, not runtime

## Error Handling

### Initialization Errors

- Web: Errors during view registration are caught and logged via `debugPrint()`
- Mobile/Desktop: JavaScript evaluation errors are caught and logged

### Message Errors

- Invalid message formats are caught and logged
- Missing iframe/WebView references are handled gracefully

### JSON Validation

- The widget does not validate JSON before sending
- Invalid JSON may cause errors in the JsonCrack widget
- Users should validate JSON before passing to the widget

## Future Extensibility

### Extra Options

The `extra` field in `JsonCrackOptions` allows passing additional options not yet defined in the package. This provides forward compatibility with new JsonCrack features without requiring package updates.

### Platform-Specific Customization

The separation of platform implementations allows for:

- Platform-specific optimizations
- Different communication protocols if needed
- Platform-specific features (e.g., Android-specific WebView settings)

## Security Considerations

### Cross-Origin Communication

- Web: Uses `postMessage` with `'*'` as target origin
- Mobile/Desktop: Uses JavaScript evaluation within the WebView

### Content Security

For self-hosted setups, users should configure appropriate CSP headers:

```
Content-Security-Policy: frame-ancestors *
Access-Control-Allow-Origin: *
```

### Data Exposure

- JSON data is passed to the iframe/WebView as strings
- Users should avoid passing sensitive data if security is a concern
- Consider the security implications of using external CDNs

## Dependencies

### Runtime Dependencies

- `flutter`: Flutter SDK
- `webview_all`: WebView implementation for mobile/desktop (conditional)
- `web`: Web APIs for web platform (conditional)

### Build-Time Dependencies

- Node.js and npm: Only needed for building `jsoncrack-react` from source

## Testing Strategy

### Unit Tests

- Test `JsonCrackOptions` serialization and equality
- Test layout direction enum behavior
- Test utility functions

### Integration Tests

- Test widget initialization on different platforms
- Test message communication flow
- Test dynamic updates
- Test error handling

### Platform Tests

- Web tests use iframe simulation
- Mobile/Desktop tests use WebView mocking
- Tests should verify platform-specific behavior

## Performance Optimization

### Lazy Loading

- The iframe/WebView is created once and reused
- Data is only sent when the widget signals readiness
- Updates are batched via `didUpdateWidget()`

### Memory Management

- Subscriptions are cleaned up in `dispose()`
- Geometry listeners are removed when no longer needed
- Scaffold references are properly managed

### Rendering Optimization

- The widget uses `Opacity` to fade in the iframe/WebView when ready
- Loading state overlays are conditionally rendered
- Pointer events are disabled when not visible (e.g., drawer open)

## Debugging

### Logging

Both implementations use `debugPrint()` for error logging:

- Initialization errors
- Message parsing errors
- JavaScript evaluation errors

### Browser DevTools (Web)

- Can inspect the iframe and its contents
- Can monitor `postMessage` communication
- Can debug the JsonCrack widget JavaScript

### WebView Debugging (Mobile/Desktop)

- Android: Use Chrome DevTools remote debugging
- iOS: Use Safari Web Inspector
- Desktop: Use platform-specific WebView debugging tools