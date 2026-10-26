# Troubleshooting

This document provides solutions to common issues encountered when using the jsoncrack Flutter package.

## Table of Contents

- [General Issues](#general-issues)
- [Web Platform Issues](#web-platform-issues)
- [Mobile/Desktop Issues](#mobiledesktop-issues)
- [Performance Issues](#performance-issues)
- [Theme Issues](#theme-issues)
- [Build Issues](#build-issues)

## General Issues

### Widget not displaying JSON

**Symptoms**: The widget shows a blank screen or loading indicator indefinitely.

**Possible Causes**:

- Invalid JSON format
- CDN connectivity issues
- Asset not bundled correctly

**Solutions**:

1. **Validate your JSON**:

   ```dart
   import 'dart:convert';

   try {
     jsonDecode(yourJsonString);
   } catch (e) {
     print('Invalid JSON: $e');
   }
   ```

2. **Check CDN connectivity**:
   - Test if `https://jsoncrack-bdf.pages.dev/cdn/` is accessible
   - Consider self-hosting if CDN is blocked in your region

3. **Verify asset bundling** (for self-hosted):
   - Ensure `assets/jsoncrack.html` is included in `pubspec.yaml`
   - Run `flutter clean && flutter pub get`

### JSON not updating dynamically

**Symptoms**: Changing the `json` parameter doesn't update the viewer.

**Solutions**:

1. **Ensure the widget is being rebuilt**:

   ```dart
   // Good: Using setState
   setState(() {
     _json = newJsonString;
   });

   // Good: Using a state management solution
   final json = Provider.of<JsonProvider>(context).json;
   ```

2. **Check for object equality**:
   - The widget uses `==` to detect changes
   - Ensure the string is actually different, not just the same value

3. **Use the `onReady` callback** to verify updates:

   ```dart
   JsonCrackView(
     json: _json,
     onReady: () {
       print('Viewer updated with new data');
     },
   )
   ```

### Options not taking effect

**Symptoms**: Changing `JsonCrackOptions` doesn't change the viewer behavior.

**Solutions**:

1. **Create a new options object**:

   ```dart
   // Good: New object
   JsonCrackOptions(
     layoutDirection: JsonCrackLayoutDirection.down,
   )

   // Bad: Modifying existing object
   _options.layoutDirection = JsonCrackLayoutDirection.down;
   ```

2. **Use copyWith for updates**:

   ```dart
   setState(() {
     _options = _options.copyWith(
       layoutDirection: JsonCrackLayoutDirection.down,
     );
   });
   ```

## Web Platform Issues

### Iframe not loading

**Symptoms**: Loading indicator persists, blank iframe, or console errors.

**Solutions**:

1. **Check browser console for errors**:
   - Open DevTools (F12)
   - Look for CORS errors, 404s, or iframe security errors

2. **Verify Content Security Policy**:
   - Ensure your CSP allows iframe embedding:

     ```
     Content-Security-Policy: frame-src 'self' https://jsoncrack-bdf.pages.dev;
     ```

3. **Check for ad blockers**:
   - Some ad blockers may block the CDN
   - Try disabling or whitelist the CDN domain

### postMessage communication failing

**Symptoms**: Widget loads but JSON is not displayed.

**Solutions**:

1. **Check for same-origin policy issues**:
   - The widget uses `postMessage` with `'*'` as target
   - Ensure no custom CSP blocks cross-origin messages

2. **Verify message listener setup**:
   - The widget should receive `{ type: 'ready' }` from the iframe
   - Check browser console for message events

3. **Test with a simple message**:

   ```dart
   // In browser console
   window.postMessage({ type: 'test' }, '*');
   ```

### Iframe conflicts with Drawer

**Symptoms**: Tapping on viewer when Drawer is open causes unexpected behavior.

**Solutions**:

1. **The package includes automatic handling**:
   - The web implementation detects when a Drawer is open
   - It disables iframe pointer events to prevent conflicts

2. **If issues persist**, ensure you're using a standard Scaffold:

   ```dart
   Scaffold(
     drawer: Drawer(...),  // Supported
     // ... other content
   )
   ```

## Mobile/Desktop Issues

### WebView not loading

**Symptoms**: Blank screen, loading indicator persists, or crash.

**Solutions**:

1. **Check WebView permissions** (Android):
   - Add to `android/app/src/main/AndroidManifest.xml`:

     ```xml
     <uses-permission android:name="android.permission.INTERNET" />
     ```

2. **Ensure WebView is available**:
   - WebView should be available on most Android devices
   - iOS/macOS includes WKWebView by default
   - Linux may require webkit2gtk

3. **Check `webview_all` compatibility**:
   - Ensure the version is compatible with your Flutter version
   - Run `flutter pub upgrade` to get the latest

### JavaScript channel not receiving messages

**Symptoms**: WebView loads but JSON is not displayed.

**Solutions**:

1. **Verify JavaScript is enabled**:
   - The implementation sets `JavaScriptMode.unrestricted`
   - Check for any settings that might disable it

2. **Check for WebView security policies**:
   - Some WebView configurations may block JavaScript evaluation
   - Ensure no custom WebView settings interfere

3. **Test JavaScript evaluation**:

   ```dart
   await _controller.runJavaScript('console.log("test")');
   ```

### Asset loading fails

**Symptoms**: Error loading the bridge HTML asset.

**Solutions**:

1. **Verify asset is bundled**:
   - Check `pubspec.yaml` includes the asset
   - Run `flutter clean && flutter pub get`

2. **Check asset path**:
   - The path should be: `packages/jsoncrack/assets/jsoncrack.html`
   - The asset is bundled with the package, not your app

3. **For local development**, ensure the package is linked:

   ```yaml
   dependencies:
     jsoncrack:
       path: ../
   ```

## Performance Issues

### Viewer is slow with large JSON

**Symptoms**: Laggy scrolling, slow zoom/pan, or crash.

**Solutions**:

1. **Reduce node count**:

   ```dart
   JsonCrackOptions(
     maxRenderableNodes: 500,  // Reduce from default 1500
   )
   ```

2. **Optimize your JSON**:
   - Remove unnecessary nested structures
   - Flatten deep hierarchies where possible
   - Limit array sizes

3. **Disable grid**:

   ```dart
   JsonCrackOptions(
     showGrid: false,  // May improve performance
   )
   ```

### High memory usage

**Symptoms**: App becomes sluggish or crashes over time.

**Solutions**:

1. **Dispose the widget properly**:

   ```dart
   @override
   void dispose() {
     // JsonCrackView will handle its own cleanup
     super.dispose();
   }
   ```

2. **Limit viewer instances**:
   - Don't create multiple JsonCrackView instances simultaneously
   - Use a single instance and update the JSON

3. **Use `onReady` to track lifecycle**:

   ```dart
   JsonCrackView(
     onReady: () {
       print('Viewer ready - memory allocated');
     },
   )
   ```

## Theme Issues

### Theme not matching app theme

**Symptoms**: Viewer is light/dark when app is dark/light.

**Solutions**:

1. **Explicitly set brightness**:

   ```dart
   JsonCrackView(
     brightness: Theme.of(context).brightness,
   )
   ```

2. **Ensure theme is available in context**:

   ```dart
   // Make sure JsonCrackView is within a MaterialApp or widget with Theme
   MaterialApp(
     theme: ThemeData(...),
     home: Scaffold(
       body: JsonCrackView(...),  // Has access to theme
     ),
   )
   ```

3. **Listen to theme changes**:

   ```dart
   class MyWidget extends StatefulWidget {
     @override
     State<MyWidget> createState() => _MyWidgetState();
   }

   class _MyWidgetState extends State<MyWidget> {
     Brightness _brightness = Brightness.light;

     @override
     void didChangeDependencies() {
       super.didChangeDependencies();
       setState(() {
         _brightness = Theme.of(context).brightness;
       });
     }

     @override
     Widget build(BuildContext context) {
       return JsonCrackView(
         brightness: _brightness,
       );
     }
   }
   ```

### Theme switching doesn't update viewer

**Symptoms**: Changing app theme doesn't update the viewer.

**Solutions**:

1. **The widget should auto-update**:
   - Changes to `brightness` parameter trigger updates via `didUpdateWidget()`
   - Ensure you're updating the state correctly

2. **Force a rebuild**:

   ```dart
   setState(() {
     _darkMode = !_darkMode;
   });
   ```

## Build Issues

### Flutter clean not fixing issues

**Symptoms**: Persistent build errors even after `flutter clean`.

**Solutions**:

1. **Clear additional caches**:

   ```bash
   flutter clean
   flutter pub cache repair
   rm -rf .dart_tool
   flutter pub get
   ```

2. **Check Flutter version**:

   ```bash
   flutter --version
   flutter upgrade
   ```

3. **Check Dart version**:

   ```bash
   dart --version
   # Ensure >= 3.8.1
   ```

### Asset not found in release builds

**Symptoms**: Works in debug but fails in release.

**Solutions**:

1. **Verify asset configuration in pubspec.yaml**:

   ```yaml
   flutter:
     assets:
       - packages/jsoncrack/assets/
   ```

2. **Build with verbose output**:

   ```bash
   flutter build apk --verbose
   flutter build web --verbose
   ```

3. **Check generated files**:
   - For web: Check `build/web/assets/`
   - For mobile: Check APK/IPK contents

### Dependency conflicts

**Symptoms**: Version conflicts with `webview_all` or other packages.

**Solutions**:

1. **Check dependency tree**:

   ```bash
   flutter pub deps
   ```

2. **Use dependency_overrides**:

   ```yaml
   dependency_overrides:
     webview_all: <specific-version>
   ```

3. **Update dependencies**:

   ```bash
   flutter pub upgrade
   ```

## Getting Help

If you encounter an issue not covered here:

1. **Check existing issues**: Search the GitHub issue tracker
2. **Create a minimal reproducible example**: Isolate the problem
3. **Include system information**:
   - Flutter version
   - Dart version
   - Platform (web, Android, iOS, etc.)
   - Package version
4. **Provide code snippets**: Show how you're using the widget
5. **Include error messages**: Full stack traces if available

## Debug Mode

### Enable verbose logging

The package uses `debugPrint()` for logging. To see all logs:

```dart
// In your main.dart or before widget creation
void main() {
  debugPrint = (String? message, {int? wrapWidth}) {
    print(message);
  };
  runApp(MyApp());
}
```

### Monitor WebView console (Mobile/Desktop)

For Android, enable WebView debugging:

```kotlin
// In android/app/src/main/kotlin/.../MainActivity.kt
import android.webkit.WebView

if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
    WebView.setWebContentsDebuggingEnabled(true)
}
```

Then use Chrome DevTools to inspect the WebView.

### Monitor iframe (Web)

Use browser DevTools to inspect the iframe:

1. Open DevTools (F12)
2. Select the iframe in the Elements panel
3. Monitor Console and Network tabs
4. Check postMessage events in the Console

## Common Mistakes

### Passing a Map instead of JSON string

**Wrong**:

```dart
JsonCrackView(
  json: {'name': 'Alice'},  // Wrong: Map, not string
)
```

**Correct**:

```dart
import 'dart:convert';

JsonCrackView(
  json: jsonEncode({'name': 'Alice'}),  // Correct: JSON string
)
```

### Not handling the ready state

**Problem**: Assuming the viewer is ready immediately.

**Solution**:

```dart
bool _viewerReady = false;

JsonCrackView(
  onReady: () {
    setState(() {
      _viewerReady = true;
    });
  },
)
```

### Modifying options in place

**Wrong**:

```dart
_options.showGrid = false;  // Won't trigger update
```

**Correct**:

```dart
setState(() {
  _options = _options.copyWith(showGrid: false);  // Triggers update
})
```
