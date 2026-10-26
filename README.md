# jsoncrack

A Flutter package that embeds the [JsonCrack](https://jsoncrack.com) JSON viewer as a widget in your Flutter application.

JsonCrack provides an interactive, visual way to explore JSON data using a graph-based tree view with zoom, pan, collapsible nodes, and more.

**[Demo App](https://jsoncrack-bdf.pages.dev)** — Try the interactive example online.

## Features

- **Visual JSON tree viewer** — renders JSON as an interactive graph with zoom and pan
- **Light and dark themes** — automatically adapts to your app's theme
- **5 configurable options** — layout direction, grid, controls, auto-center, and node limit
- **Type-safe API** — use `JsonCrackLayoutDirection` enum for compile-time safety
- **Ready-state callback** — know when the viewer is fully loaded via `onReady`
- **Custom loading UI** — provide a custom loading indicator with `loadingBuilder`
- **Cross-platform** — works on web (iframe), mobile, and desktop (InAppWebView)
- **Responsive example app** — the demo app adapts to mobile with a drawer, bottom sheet editor, and compact status bar
- **Easy to use** — drop-in widget with minimal setup

## Getting started

### 1. Add the dependency

Add `jsoncrack` to your `pubspec.yaml`:

```yaml
dependencies:
  jsoncrack: ^0.2.0
```

Or install via the command line:

```bash
flutter pub add jsoncrack
```

### 2. Use the widget

No manual build or local web server is required! By default, the widget connects to the official hosted CDN (`https://jsoncrack-bdf.pages.dev/cdn/`):

```dart
import 'package:flutter/material.dart';
import 'package:jsoncrack/jsoncrack.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: JsonCrackView(
          json: '''
{
  "name": "Alice",
  "age": 25,
  "hobbies": ["reading", "coding", "hiking"]
}
          ''',
        ),
      ),
    );
  }
}
```

## Usage

### Basic usage

```dart
JsonCrackView(
  json: '{"key": "value"}',
)
```

### With type-safe options

```dart
JsonCrackView(
  json: '{"key": "value"}',
  brightness: Brightness.dark,
  options: JsonCrackOptions(
    layoutDirection: JsonCrackLayoutDirection.down,
    showGrid: false,
  ),
)
```

### With ready callback

```dart
JsonCrackView(
  json: '{"key": "value"}',
  onReady: () {
    print('Viewer is ready and displaying data');
  },
)
```

### With custom loading UI

```dart
JsonCrackView(
  json: '{"key": "value"}',
  loadingBuilder: (context, progress) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading JSON viewer...'),
        ],
      ),
    );
  },
)
```

### Available options

| Option              | Type                              | Default   | Description                                              |
|---------------------|-----------------------------------|-----------|----------------------------------------------------------|
| `layoutDirection`   | `JsonCrackLayoutDirection` / `String` | `right` | Tree layout direction (`right`, `down`, `left`, `up`)     |
| `showGrid`          | `bool`                            | `true`    | Show the background grid                                 |
| `showControls`      | `bool`                            | `false`   | Show built-in pan/zoom camera controls                   |
| `centerOnLayout`    | `bool`                            | `true`    | Auto-center the view on layout changes                   |
| `maxRenderableNodes`| `int`                             | `1500`    | Maximum nodes to render before showing a fallback        |

### Layout directions

```dart
JsonCrackLayoutDirection.right  // Tree grows to the right (default)
JsonCrackLayoutDirection.down   // Tree grows downward
JsonCrackLayoutDirection.left   // Tree grows to the left
JsonCrackLayoutDirection.up     // Tree grows upward
```

For backward compatibility, string values are also accepted:

```dart
JsonCrackOptions(layoutDirection: 'DOWN')
```

### Customization examples

#### Show pan/zoom controls

Enable built-in camera controls for users who prefer button-based navigation:

```dart
JsonCrackView(
  json: myJson,
  options: JsonCrackOptions(
    showControls: true,
  ),
)
```

#### Limit renderable nodes

For large JSON payloads, cap the number of rendered nodes to maintain performance:

```dart
JsonCrackView(
  json: largeJson,
  options: JsonCrackOptions(
    maxRenderableNodes: 500,
  ),
)
```

> **Tip:** For smooth interaction, keep `maxRenderableNodes` between 300–500. The default is 1500.

### Hosting & Self-Embedding

By default, the package automatically loads the widget from the hosted Cloudflare CDN:

```
https://jsoncrack-bdf.pages.dev/cdn/
```

Because the widget is hosted on a high-availability CDN, no local web server or build step is needed in your Flutter projects.

#### Using your own self-hosted widget or CDN

If you prefer to self-host or embed your own copy (for air-gapped environments or custom branding):

1. Copy the prebuilt [`jsoncrack-react/`](jsoncrack-react/) directory from this repository to your web server, CDN, or hosting provider. (You can also rebuild it at any time using `./build-json-crack.sh` or `make export`).
2. Ensure your server headers allow cross-origin iframe embedding:

   ```http
   Content-Security-Policy: frame-ancestors *
   Access-Control-Allow-Origin: *
   ```

3. Pass your custom URL to `JsonCrackView`:

```dart
JsonCrackView(
  json: '{"key": "value"}',
  url: 'https://your-domain.com/cdn/',
)
```

### Updating JSON dynamically

The widget automatically detects changes and updates the viewer:

```dart
JsonCrackView(
  json: _currentJson, // When this changes, the viewer updates
  options: _currentOptions,
)
```

## Demo

A live demo app is available at **[jsoncrack-bdf.pages.dev](https://jsoncrack-bdf.pages.dev)**. It showcases all customization options, theme switching, sample datasets, and responsive mobile support including:

- **Desktop**: Full layout with sidebar, editor panel, and status bar
- **Tablet**: Viewer-focused layout with compact controls
- **Mobile**: Full-width viewer with drawer navigation, bottom sheet JSON editor, and floating action button

## Architecture

The package uses a platform-specific implementation:

- **Web**: An iframe loads the JsonCrack widget, communicating via `postMessage`.
- **Mobile/Desktop**: `WebViewWidget` (via `webview_all`) renders the HTML and communicates via JavaScript evaluation.

The `JsonCrackView` widget automatically selects the correct implementation at compile time using Dart's conditional imports.

## Example project

See the [`example/`](example/) directory for a complete Flutter app that demonstrates:

- Theme switching (light/dark)
- Layout direction toggling with type-safe enum
- All 5 customization options
- Dynamic JSON input with real-time validation
- 6 preset sample JSON datasets
- Node count display
- Viewer ready-state notification
- JSON formatting and reset
- **Responsive mobile support** — narrow layout with drawer, bottom sheet editor, and compact status bar

To run the example:

```bash
make example-web
```

## Requirements

- Flutter SDK >= 1.17.0
- Dart SDK >= 3.8.1
- Node.js and npm (only needed if building `jsoncrack-react` from source)

## Additional Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) — Detailed technical architecture documentation
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) — Common issues and solutions
- [CHANGELOG.md](CHANGELOG.md) — Version history and changes

## License

See the [LICENSE](LICENSE) file for details.

## Copyright

© 2025 floriansabate.top
