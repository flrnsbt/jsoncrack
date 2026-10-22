# jsoncrack

A Flutter package that embeds the [JsonCrack](https://jsoncrack.com) JSON viewer as a widget in your Flutter application.

JsonCrack provides an interactive, visual way to explore and edit JSON data using a graph-based tree view.

## Features

- **Visual JSON tree viewer** — renders JSON as an interactive graph
- **Light and dark themes** — automatically adapts to your app's theme
- **Configurable layout** — control layout direction and grid visibility
- **Cross-platform** — works on web, mobile, and desktop
- **Easy to use** — drop-in widget with minimal setup

## Getting started

### 1. Add the dependency

Add `jsoncrack` to your `pubspec.yaml`:

```yaml
dependencies:
  jsoncrack: ^0.1.0
```

Or install via the command line:

```bash
flutter pub add jsoncrack
```

### 2. Build the HTML asset

The package requires the JsonCrack HTML application to be built and placed in the `assets/` directory. Use the provided `Makefile`:

```bash
make html
```

This clones the JsonCrack repository, builds the widget page, and places the output in `assets/src/`.

### 3. Use the widget

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

### With custom options

```dart
JsonCrackView(
  json: '{"key": "value"}',
  brightness: Brightness.dark,
  options: JsonCrackOptions(
    layoutDirection: 'DOWN',
  ),
)
```

### Available options

| Option            | Type    | Default   | Description                                  |
|-------------------|---------|-----------|----------------------------------------------|
| `layoutDirection` | String  | `'RIGHT'` | Tree layout direction (`'RIGHT'`, `'DOWN'`, `'LEFT'`, `'UP'`) |
| `showGrid`        | bool    | `true`    | Show the background grid                     |

### Using a custom URL

If you host the JsonCrack HTML app elsewhere, you can specify a custom URL:

```dart
JsonCrackView(
  json: '{"key": "value"}',
  url: 'https://your-domain.com/jsoncrack.html',
)
```

## Example project

See the [`example/`](example/) directory for a complete Flutter web app that demonstrates theme switching, layout direction toggling, and dynamic JSON input.

To run the example:

```bash
make example-web
```
