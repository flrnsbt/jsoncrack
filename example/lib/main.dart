import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:jsoncrack/jsoncrack.dart';

void main() => runApp(const JsonCrackExampleApp());

/// A feature-rich demo app that showcases the jsoncrack package.
///
/// Demonstrates:
/// - Theme switching (light/dark)
/// - Layout direction toggling with type-safe enum
/// - Dynamic JSON input with real-time validation
/// - Preset sample data with 6 diverse examples
/// - Responsive sidebar layout
/// - Loading state indicators
/// - JSON formatting and reset
/// - Viewer settings dialog
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
  'Array of Objects': '''{
  "employees": [
    {
      "id": 101,
      "name": "Diana Prince",
      "department": "Engineering",
      "skills": ["Python", "Dart", "Flutter"],
      "projects": [
        {"name": "Project Alpha", "role": "Lead"},
        {"name": "Project Beta", "role": "Contributor"}
      ]
    },
    {
      "id": 102,
      "name": "Bruce Wayne",
      "department": "Design",
      "skills": ["Figma", "UI/UX", "Prototyping"],
      "projects": [
        {"name": "Project Alpha", "role": "Designer"}
      ]
    },
    {
      "id": 103,
      "name": "Clark Kent",
      "department": "Marketing",
      "skills": ["SEO", "Content", "Analytics"],
      "projects": []
    }
  ],
  "company": {
    "name": "Example Corp",
    "founded": 2020,
    "headquarters": "Metropolis"
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
  JsonCrackLayoutDirection _layoutDirection = JsonCrackLayoutDirection.right;
  bool _showGrid = true;
  bool _showControls = false;
  int _maxRenderableNodes = 1500;
  bool _sidebarOpen = true;
  String _selectedSample = 'User Profile';
  late TextEditingController _jsonController;
  String? _jsonError;
  bool _viewerReady = false;

  @override
  void initState() {
    super.initState();
    _jsonController = TextEditingController(
      text: kSampleJsonData[_selectedSample],
    );
  }

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  String get _jsonInput => _jsonController.text;

  String? get _url => '/cdn/index.html';

  bool get _isValidJson {
    try {
      jsonDecode(_jsonInput);
      return true;
    } catch (_) {
      return false;
    }
  }

  int get _jsonSize {
    try {
      final parsed = jsonDecode(_jsonInput);
      return _countNodes(parsed);
    } catch (_) {
      return 0;
    }
  }

  int _countNodes(Object obj) {
    if (obj is Map) {
      var count = obj.length;
      for (final value in obj.values) {
        count += _countNodes(value);
      }
      return count;
    }
    if (obj is List) {
      var count = obj.length;
      for (final item in obj) {
        count += _countNodes(item);
      }
      return count;
    }
    return 0;
  }

  JsonCrackOptions get _options => JsonCrackOptions(
    layoutDirection: _layoutDirection,
    showGrid: _showGrid,
    showControls: _showControls,
    maxRenderableNodes: _maxRenderableNodes,
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

  void _onViewerReady() {
    _viewerReady = true;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isWide = MediaQuery.of(context).size.width > 800;
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('JsonCrack Example'),
        leading: isWide
            ? IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'Toggle sidebar',
                onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
              )
            : null,
        actions: [
          if (_viewerReady)
            Tooltip(
              message: 'Viewer ready',
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
              ),
            ),
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
      drawer: isWide ? null : _buildDrawer(),
      body: isWide
          ? _buildWideLayout(isDark)
          : _buildNarrowLayout(isDark, isNarrow),
      floatingActionButton: isNarrow
          ? FloatingActionButton(
              onPressed: () => _showEditorBottomSheet(context),
              tooltip: 'Edit JSON',
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  /// Drawer for mobile and tablet screens with sample selection and actions.
  Widget _buildDrawer() {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Samples',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: kSampleJsonData.keys.length,
                separatorBuilder: (_, __) => const SizedBox(height: 4),
                itemBuilder: (context, index) {
                  final sample = kSampleJsonData.keys.elementAt(index);
                  return ListTile(
                    dense: true,
                    selected: _selectedSample == sample,
                    title: Text(sample),
                    onTap: () {
                      _selectSample(sample);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const Divider(),
            FilledButton.icon(
              onPressed: () {
                _formatJson();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.format_indent_increase, size: 18),
              label: const Text('Format JSON'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                _selectSample(_selectedSample);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Reset'),
            ),
          ],
        ),
      ),
    );
  }

  /// Wide layout with NavigationRail sidebar and editor panel (desktop).
  Widget _buildWideLayout(bool isDark) {
    return Row(
      children: [
        if (_sidebarOpen)
          NavigationRail(
            extended: true,
            leading: _sampleSelector(),
            trailing: _actionButtons(),
            labelType: NavigationRailLabelType.none,
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
                child: JsonCrackView(
                  json: _jsonInput,
                  url: _url,
                  brightness: isDark ? Brightness.dark : Brightness.light,
                  options: _options,
                  onReady: _onViewerReady,
                ),
              ),
            ],
          ),
        ),
        if (_sidebarOpen) Expanded(child: _editorPanel()),
      ],
    );
  }

  /// Narrow layout for mobile and tablet screens.
  Widget _buildNarrowLayout(bool isDark, bool isNarrow) {
    return Column(
      children: [
        if (isNarrow) _mobileStatusBar(),
        if (!isNarrow) _statusBar(),
        Expanded(
          child: JsonCrackView(
            url: _url,
            json: _jsonInput,
            brightness: isDark ? Brightness.dark : Brightness.light,
            options: _options,
            onReady: _onViewerReady,
          ),
        ),
      ],
    );
  }

  /// Compact status bar for mobile screens.
  Widget _mobileStatusBar() {
    final theme = Theme.of(context);
    final isValid = _isValidJson;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            size: 14,
            color: isValid
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          const SizedBox(width: 4),
          Text(
            isValid ? 'Valid' : 'Invalid',
            style: TextStyle(
              fontSize: 11,
              color: isValid
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
          if (isValid) ...[
            const SizedBox(width: 8),
            Text(
              '$_jsonSize nodes',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
          const Spacer(),
          Text(
            _layoutDirection.name.toUpperCase(),
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  /// Bottom sheet editor for mobile screens.
  void _showEditorBottomSheet(BuildContext context) {
    final localController = TextEditingController(text: _jsonInput);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                  TextButton(
                    onPressed: () {
                      _formatJson();
                      localController.text = _jsonInput;
                    },
                    child: const Text('Format'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      _selectSample(_selectedSample);
                      localController.text = _jsonInput;
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.5,
                ),
                child: TextField(
                  controller: localController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Paste your JSON here...',
                    isDense: true,
                  ),
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    setState(() {
                      _jsonController.text = localController.text;
                      try {
                        jsonDecode(localController.text);
                        _jsonError = null;
                      } catch (e) {
                        _jsonError = e.toString();
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sampleSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
                label: Text(
                  sample,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
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
            color: isValid
                ? theme.colorScheme.primary
                : theme.colorScheme.error,
          ),
          const SizedBox(width: 8),
          Text(
            isValid ? 'Valid JSON' : 'Invalid JSON',
            style: TextStyle(
              fontSize: 13,
              color: isValid
                  ? theme.colorScheme.primary
                  : theme.colorScheme.error,
            ),
          ),
          if (isValid) ...[
            const SizedBox(width: 16),
            Icon(
              Icons.account_tree,
              size: 16,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 4),
            Text(
              '$_jsonSize nodes',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
          const Spacer(),
          Text(
            'Direction: ${_layoutDirection.name.toUpperCase()}',
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
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
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
    final result = await showDialog<ViewerSettings>(
      context: context,
      builder: (context) => ViewerSettingsDialog(
        initialDirection: _layoutDirection,
        initialShowGrid: _showGrid,
        initialShowControls: _showControls,
        initialMaxRenderableNodes: _maxRenderableNodes,
      ),
    );
    if (mounted) {
      setState(() {
        if (result != null) {
          _layoutDirection = result.direction;
          _showGrid = result.showGrid;
          _showControls = result.showControls;
          _maxRenderableNodes = result.maxRenderableNodes;
        }
      });
    }
  }
}

/// Data class holding viewer settings selected by the user.
class ViewerSettings {
  final JsonCrackLayoutDirection direction;
  final bool showGrid;
  final bool showControls;
  final int maxRenderableNodes;

  const ViewerSettings({
    required this.direction,
    required this.showGrid,
    this.showControls = false,
    this.maxRenderableNodes = 1500,
  });
}

/// A dialog widget for configuring JsonCrack viewer settings.
///
/// Returns the selected [ViewerSettings] when the user confirms,
/// or `null` if the dialog is cancelled.
class ViewerSettingsDialog extends StatefulWidget {
  final JsonCrackLayoutDirection initialDirection;
  final bool initialShowGrid;
  final bool initialShowControls;
  final int initialMaxRenderableNodes;

  const ViewerSettingsDialog({
    super.key,
    required this.initialDirection,
    required this.initialShowGrid,
    this.initialShowControls = false,
    this.initialMaxRenderableNodes = 1500,
  });

  @override
  State<ViewerSettingsDialog> createState() => _ViewerSettingsDialogState();
}

class _ViewerSettingsDialogState extends State<ViewerSettingsDialog> {
  late JsonCrackLayoutDirection _direction;
  late bool _showGrid;
  late bool _showControls;
  late int _maxRenderableNodes;

  @override
  void initState() {
    super.initState();
    _direction = widget.initialDirection;
    _showGrid = widget.initialShowGrid;
    _showControls = widget.initialShowControls;
    _maxRenderableNodes = widget.initialMaxRenderableNodes;
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
            DropdownButtonFormField<JsonCrackLayoutDirection>(
              initialValue: _direction,
              isDense: true,
              items: const [
                DropdownMenuItem(
                  value: JsonCrackLayoutDirection.right,
                  child: Text('Right'),
                ),
                DropdownMenuItem(
                  value: JsonCrackLayoutDirection.down,
                  child: Text('Down'),
                ),
                DropdownMenuItem(
                  value: JsonCrackLayoutDirection.left,
                  child: Text('Left'),
                ),
                DropdownMenuItem(
                  value: JsonCrackLayoutDirection.up,
                  child: Text('Up'),
                ),
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
            const SizedBox(height: 16),
            const Text(
              'Interaction',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Show Controls'),
              subtitle: const Text('Display pan/zoom buttons'),
              value: _showControls,
              onChanged: (value) {
                setState(() => _showControls = value);
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Performance',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: const Text('Max Renderable Nodes'),
              subtitle: Text(
                'Current: $_maxRenderableNodes (recommended: 300–500)',
              ),
              trailing: TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      final controller = TextEditingController(
                        text: '$_maxRenderableNodes',
                      );
                      return AlertDialog(
                        title: const Text('Max Renderable Nodes'),
                        content: TextField(
                          controller: controller,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Enter max nodes (e.g. 1500)',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              final value = int.tryParse(controller.text);
                              if (value != null && value > 0) {
                                setState(() => _maxRenderableNodes = value);
                                Navigator.pop(ctx);
                              }
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: const Text('Change'),
              ),
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
              ViewerSettings(
                direction: _direction,
                showGrid: _showGrid,
                showControls: _showControls,
                maxRenderableNodes: _maxRenderableNodes,
              ),
            );
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}
