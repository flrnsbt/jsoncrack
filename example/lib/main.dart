import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jsoncrack/jsoncrack.dart';

void main() => runApp(const JsonCrackExampleApp());

/// A feature-rich demo app that showcases the jsoncrack package.
///
/// Demonstrates:
/// - Theme switching (light/dark)
/// - Layout direction toggling
/// - Dynamic JSON input with validation
/// - Preset sample data
/// - Responsive sidebar layout
class JsonCrackExampleApp extends StatefulWidget {
  const JsonCrackExampleApp({super.key});

  @override
  State<JsonCrackExampleApp> createState() => _JsonCrackExampleAppState();
}

class _JsonCrackExampleAppState extends State<JsonCrackExampleApp> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JsonCrack Example',
      debugShowCheckedModeBanner: false,
      theme: _darkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      home: _Home(onThemeToggle: () => setState(() => _darkMode = !_darkMode)),
    );
  }
}

/// Preset JSON samples for quick demonstration.
const kSampleJsonData = {
  'User Profile': '''{
  "name": "Alice Johnson",
  "age": 28,
  "email": "alice@example.com",
  "address": {
    "street": "123 Main St",
    "city": "Springfield",
    "state": "IL",
    "zip": "62701"
  },
  "hobbies": ["reading", "coding", "hiking"],
  "scores": [95, 87, 92, 78, 100],
  "isActive": true,
  "metadata": {
    "createdAt": "2024-01-15T10:30:00Z",
    "tags": ["user", "premium"]
  }
}''',
  'API Response': '''{
  "status": 200,
  "message": "Success",
  "data": {
    "users": [
      {
        "id": 1,
        "name": "Alice",
        "role": "admin",
        "permissions": ["read", "write", "delete"]
      },
      {
        "id": 2,
        "name": "Bob",
        "role": "editor",
        "permissions": ["read", "write"]
      },
      {
        "id": 3,
        "name": "Charlie",
        "role": "viewer",
        "permissions": ["read"]
      }
    ],
    "pagination": {
      "page": 1,
      "perPage": 10,
      "total": 3
    }
  }
}''',
  'Nested Config': '''{
  "app": {
    "name": "MyApp",
    "version": "2.1.0",
    "features": {
      "auth": {
        "enabled": true,
        "providers": ["google", "github", "email"],
        "sessionTimeout": 3600
      },
      "notifications": {
        "email": true,
        "push": true,
        "sms": false
      },
      "analytics": {
        "tracking": true,
        "events": ["page_view", "click", "purchase"]
      }
    },
    "database": {
      "host": "localhost",
      "port": 5432,
      "name": "myapp_db",
      "pool": {
        "min": 2,
        "max": 10,
        "idleTimeout": 30000
      }
    }
  }
}''',
  'Product Catalog': '''{
  "products": [
    {
      "id": "p1",
      "name": "Laptop Pro",
      "price": 1299.99,
      "inStock": true,
      "specs": {
        "cpu": "M2 Pro",
        "ram": "16GB",
        "storage": "512GB SSD"
      },
      "reviews": [
        {"user": "Alice", "rating": 5, "comment": "Excellent!"},
        {"user": "Bob", "rating": 4, "comment": "Great performance"}
      ]
    },
    {
      "id": "p2",
      "name": "Wireless Mouse",
      "price": 49.99,
      "inStock": true,
      "specs": {
        "dpi": 16000,
        "battery": "18 months",
        "connectivity": ["Bluetooth", "USB-C"]
      },
      "reviews": [
        {"user": "Charlie", "rating": 4, "comment": "Comfortable grip"}
      ]
    },
    {
      "id": "p3",
      "name": "USB-C Hub",
      "price": 79.99,
      "inStock": false,
      "specs": {
        "ports": ["HDMI", "USB-C", "USB-A x2", "SD Card"],
        "powerDelivery": "100W"
      },
      "reviews": []
    }
  ]
}''',
  'Deeply Nested': '''{
  "level1": {
    "level2": {
      "level3": {
        "level4": {
          "level5": {
            "value": "deep",
            "metadata": {
              "path": "level1.level2.level3.level4.level5",
              "depth": 5
            }
          }
        }
      }
    }
  },
  "siblings": {
    "a": {"nested": {"x": 1, "y": 2}},
    "b": {"nested": {"x": 3, "y": 4}},
    "c": {"nested": {"x": 5, "y": 6}}
  }
}''',
};

/// Home widget for the example app.
///
/// Manages all state including JSON input, layout direction,
/// and sidebar visibility. Fully inherits Material App theming
/// from the parent [JsonCrackExampleApp].
class _Home extends StatefulWidget {
  final VoidCallback onThemeToggle;

  const _Home({required this.onThemeToggle});

  @override
  State<_Home> createState() => _HomeState();
}

class _HomeState extends State<_Home> {
  String _layoutDirection = 'RIGHT';
  bool _showGrid = true;
  bool _sidebarOpen = true;
  String _selectedSample = 'User Profile';
  late TextEditingController _jsonController;
  String? _jsonError;
  bool _dialogOpen = false;

  @override
  void initState() {
    super.initState();
    _jsonController = TextEditingController(text: kSampleJsonData[_selectedSample]);
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  String get _jsonInput => _jsonController.text;

  bool get _isValidJson {
    try {
      jsonDecode(_jsonInput);
      return true;
    } catch (_) {
      return false;
    }
  }

  JsonCrackOptions get _options => JsonCrackOptions(
        layoutDirection: _layoutDirection,
        showGrid: _showGrid,
      );

  void _selectSample(String sample) {
    setState(() {
      _selectedSample = sample;
      _jsonController.text = kSampleJsonData[sample]!;
      _jsonError = null;
    });
  }

  void _formatJson() {
    try {
      final parsed = jsonDecode(_jsonInput);
      _jsonController.value = _jsonController.value.copyWith(
        text: JsonEncoder.withIndent('  ').convert(parsed),
        selection: TextSelection.collapsed(offset: 0),
      );
      setState(() => _jsonError = null);
    } catch (e) {
      setState(() => _jsonError = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JsonCrack Example'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          tooltip: 'Toggle sidebar',
          onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
            onPressed: widget.onThemeToggle,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Viewer settings',
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Row(
        children: [
          if (_sidebarOpen)
            NavigationRail(
              extended: isWide,
              leading: _sampleSelector(),
              trailing: _actionButtons(),
              labelType: isWide ? NavigationRailLabelType.none : NavigationRailLabelType.all,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.code),
                  label: Text('Editor'),
                ),
              ],
              selectedIndex: 0,
            ),
          if (_sidebarOpen) const VerticalDivider(width: 1),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                _statusBar(),
                Expanded(
                  child: Offstage(
                    offstage: _dialogOpen,
                    child: JsonCrackView(
                      json: _jsonInput,
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      options: _options,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_sidebarOpen)
            Expanded(
              child: _editorPanel(),
            ),
        ],
      ),
    );
  }

  Widget _sampleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Samples',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          ...kSampleJsonData.keys.map((sample) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: ChoiceChip(
                label: Text(sample),
                selected: _selectedSample == sample,
                onSelected: (_) => _selectSample(sample),
                labelStyle: const TextStyle(fontSize: 11),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton.icon(
            onPressed: _formatJson,
            icon: const Icon(Icons.format_indent_increase, size: 18),
            label: const Text('Format'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _selectSample(_selectedSample),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Widget _statusBar() {
    final theme = Theme.of(context);
    final isValid = _isValidJson;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            size: 18,
            color: isValid ? theme.colorScheme.primary : theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            isValid ? 'Valid JSON' : 'Invalid JSON: $_jsonError',
            style: TextStyle(
              fontSize: 13,
              color: isValid ? theme.colorScheme.primary : theme.colorScheme.error,
            ),
          ),
          const Spacer(),
          Text(
            'Direction: $_layoutDirection',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _editorPanel() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.code, size: 18),
              const SizedBox(width: 8),
              const Text(
                'JSON Editor',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_jsonError != null)
                Tooltip(
                  message: _jsonError!,
                  child: const Icon(Icons.error, size: 18, color: Colors.red),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _jsonController,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
                hintText: 'Paste your JSON here...',
                isDense: true,
              ),
              keyboardType: TextInputType.multiline,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
              onChanged: (value) {
                setState(() {
                  try {
                    jsonDecode(value);
                    _jsonError = null;
                  } catch (e) {
                    _jsonError = e.toString();
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    setState(() => _dialogOpen = true);
    final result = await showDialog<ViewerSettings>(
      context: context,
      builder: (context) => ViewerSettingsDialog(
        initialDirection: _layoutDirection,
        initialShowGrid: _showGrid,
      ),
    );
    if (mounted) {
      setState(() {
        _dialogOpen = false;
        if (result != null) {
          _layoutDirection = result.direction;
          _showGrid = result.showGrid;
        }
      });
    }
  }
}

/// Data class holding viewer settings selected by the user.
class ViewerSettings {
  final String direction;
  final bool showGrid;

  const ViewerSettings({required this.direction, required this.showGrid});
}

/// A dialog widget for configuring JsonCrack viewer settings.
///
/// Returns the selected [ViewerSettings] when the user confirms,
/// or `null` if the dialog is cancelled.
class ViewerSettingsDialog extends StatefulWidget {
  final String initialDirection;
  final bool initialShowGrid;

  const ViewerSettingsDialog({
    super.key,
    required this.initialDirection,
    required this.initialShowGrid,
  });

  @override
  State<ViewerSettingsDialog> createState() => _ViewerSettingsDialogState();
}

class _ViewerSettingsDialogState extends State<ViewerSettingsDialog> {
  late String _direction;
  late bool _showGrid;

  @override
  void initState() {
    super.initState();
    _direction = widget.initialDirection;
    _showGrid = widget.initialShowGrid;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Viewer Settings'),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            const Text(
              'Layout Direction',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _direction,
              isDense: true,
              items: const [
                DropdownMenuItem(value: 'RIGHT', child: Text('Right')),
                DropdownMenuItem(value: 'DOWN', child: Text('Down')),
                DropdownMenuItem(value: 'LEFT', child: Text('Left')),
                DropdownMenuItem(value: 'UP', child: Text('Up')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _direction = value);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Show Grid'),
              subtitle: const Text('Display grid lines in the viewer'),
              value: _showGrid,
              onChanged: (value) {
                setState(() => _showGrid = value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              ViewerSettings(direction: _direction, showGrid: _showGrid),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
