# jsoncrack_example

A comprehensive demo application showcasing the [jsoncrack](https://pub.dev/packages/jsoncrack) Flutter package.

This example demonstrates all features and customization options of the JsonCrack JSON viewer widget, including theme switching, responsive layouts, and dynamic JSON input.

## Features

This example app showcases:

- **Theme switching** — Toggle between light and dark modes
- **Layout direction control** — Switch between right, down, left, and up tree layouts using the type-safe `JsonCrackLayoutDirection` enum
- **Dynamic JSON input** — Real-time JSON validation and visualization
- **6 preset samples** — Pre-loaded JSON datasets (User Profile, API Response, Nested Config, Product Catalog, Deeply Nested, Array of Objects)
- **Viewer settings** — Customizable options via dialog (grid, controls, max renderable nodes)
- **Responsive design** — Adapts to different screen sizes:
  - **Desktop**: Full layout with sidebar, editor panel, and status bar
  - **Tablet**: Viewer-focused layout with compact controls
  - **Mobile**: Full-width viewer with drawer navigation, bottom sheet JSON editor, and floating action button
- **Node count display** — Shows the number of JSON nodes being rendered
- **Viewer ready-state notification** — Visual indicator when the viewer is fully loaded
- **JSON formatting** — Auto-format JSON with proper indentation
- **Reset functionality** — Quickly revert to the original sample data

## Running the Example

### Web (Recommended)

```bash
flutter pub get
flutter run -d chrome
```

Or use the Makefile from the parent directory:

```bash
cd ..
make example-web
```

### Mobile/Desktop

```bash
flutter pub get
flutter run
```

Select your target device when prompted.

## Project Structure

```
lib/
└── main.dart          # Main application code with all demo features
assets/                # Local assets (if any)
web/
└── cdn/               # JsonCrack widget files (build with `make export` or `./build-json-crack.sh`)
```

## Key Components

### JsonCrackExampleApp
The root application widget that manages theme state and wraps the MaterialApp.

### _Home
The main home screen widget that manages:
- JSON input and validation
- Layout direction state
- Sidebar visibility
- Sample selection
- Responsive layout switching

### Sample Data
Six diverse JSON samples are included to demonstrate different use cases:
- **User Profile**: Simple nested object with arrays
- **API Response**: Complex structure with pagination
- **Nested Config**: Multi-level configuration object
- **Product Catalog**: Array of objects with nested reviews
- **Deeply Nested**: Tests deep nesting capabilities
- **Array of Objects**: Employees with nested projects

## Customization Examples

### Basic Usage

```dart
JsonCrackView(
  json: '{"name": "Alice", "age": 25}',
)
```

### With Options

```dart
JsonCrackView(
  json: '{"key": "value"}',
  brightness: Brightness.dark,
  options: JsonCrackOptions(
    layoutDirection: JsonCrackLayoutDirection.down,
    showGrid: false,
    showControls: true,
    maxRenderableNodes: 500,
  ),
)
```

### With Ready Callback

```dart
JsonCrackView(
  json: '{"key": "value"}',
  onReady: () {
    print('Viewer is ready and displaying data');
  },
)
```

## Platform Support

This example app runs on:
- **Web**: Uses iframe-based implementation
- **Android/iOS**: Uses WebView widget
- **Linux/macOS/Windows**: Uses WebView widget

## Dependencies

- `flutter`: Flutter SDK
- `jsoncrack`: The parent package (local path dependency)

## Additional Resources

- [Main Package README](../README.md) — Full package documentation
- [JsonCrack Website](https://jsoncrack.com) — Original web-based JSON viewer
- [Live Demo](https://jsoncrack-bdf.pages.dev) — Interactive web demo
- [Flutter Documentation](https://docs.flutter.dev) — Flutter development guides
