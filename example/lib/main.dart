import 'package:drag_split_layout/drag_split_layout.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag Split Layout Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LayoutEditorDemo(),
    );
  }
}

/// Model for palette items that can be dragged into the layout
class PaletteItem {
  const PaletteItem({
    required this.type,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String type;
  final String title;
  final IconData icon;
  final Color color;
}

/// Available palette items
const List<PaletteItem> paletteItems = [
  PaletteItem(
    type: 'editor',
    title: 'Code Editor',
    icon: Icons.code,
    color: Colors.teal,
  ),
  PaletteItem(
    type: 'terminal',
    title: 'Terminal',
    icon: Icons.terminal,
    color: Colors.blueGrey,
  ),
  PaletteItem(
    type: 'preview',
    title: 'Preview',
    icon: Icons.visibility,
    color: Colors.orange,
  ),
  PaletteItem(
    type: 'explorer',
    title: 'Explorer',
    icon: Icons.folder,
    color: Colors.amber,
  ),
  PaletteItem(
    type: 'output',
    title: 'Output',
    icon: Icons.output,
    color: Colors.purple,
  ),
  PaletteItem(
    type: 'debug',
    title: 'Debug',
    icon: Icons.bug_report,
    color: Colors.red,
  ),
  PaletteItem(
    type: 'search',
    title: 'Search',
    icon: Icons.search,
    color: Colors.cyan,
  ),
  PaletteItem(
    type: 'git',
    title: 'Git',
    icon: Icons.commit,
    color: Colors.deepOrange,
  ),
];

class LayoutEditorDemo extends StatefulWidget {
  const LayoutEditorDemo({super.key});

  @override
  State<LayoutEditorDemo> createState() => _LayoutEditorDemoState();
}

class _LayoutEditorDemoState extends State<LayoutEditorDemo> {
  late SplitLayoutController _controller;
  bool _editMode = true;
  int _panelCounter = 0;

  @override
  void initState() {
    super.initState();
    _controller = SplitLayoutController(
      rootNode: _buildInitialLayout(),
    );
  }

  SplitNode _buildInitialLayout() {
    return SplitNode.branch(
      id: 'root',
      axis: SplitAxis.horizontal,
      children: [
        SplitNode.leaf(
          id: 'initial_editor',
          widgetBuilder: (_) => const PanelWidget(
            title: 'Code Editor',
            icon: Icons.code,
            color: Colors.teal,
          ),
        ),
        SplitNode.leaf(
          id: 'initial_preview',
          widgetBuilder: (_) => const PanelWidget(
            title: 'Preview',
            icon: Icons.visibility,
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  SplitNode _createNodeFromPaletteItem(PaletteItem item) {
    final id = '${item.type}_${_panelCounter++}';
    return SplitNode.leaf(
      id: id,
      widgetBuilder: (_) => PanelWidget(
        title: item.title,
        icon: item.icon,
        color: item.color,
      ),
    );
  }

  void _resetLayout() {
    _controller.updateRootNode(_buildInitialLayout());
    _panelCounter = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Layout Editor'),
        actions: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Edit Mode'),
              const SizedBox(width: 8),
              Switch(
                value: _editMode,
                onChanged: (value) {
                  setState(() {
                    _editMode = value;
                    _controller.editMode = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Layout',
            onPressed: _resetLayout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Instructions bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _editMode
                        ? 'Drag components from the right panel into the layout. '
                            'Drop on edges to split, center to replace.'
                        : 'Edit mode disabled. Toggle to enable drag & drop.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Row(
              children: [
                // Layout editor area
                Expanded(
                  child: _buildLayoutArea(),
                ),
                // Right panel with draggable components
                if (_editMode) _buildComponentPalette(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutArea() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: _PaletteDropTarget(
        controller: _controller,
        editMode: _editMode,
        onPaletteItemDropped: _createNodeFromPaletteItem,
      ),
    );
  }

  Widget _buildComponentPalette() {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(top: 8, right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  Icons.widgets,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Components',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: paletteItems.length,
              itemBuilder: (context, index) {
                return _DraggablePaletteItem(item: paletteItems[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A draggable item in the component palette
class _DraggablePaletteItem extends StatelessWidget {
  const _DraggablePaletteItem({required this.item});

  final PaletteItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Draggable<PaletteItem>(
        data: item,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: item.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: item.color.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(item.icon, color: item.color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    color: item.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.drag_indicator,
                color: item.color.withValues(alpha: 0.5),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom widget that wraps EditableMultiSplitView and also accepts
/// drops from the palette
class _PaletteDropTarget extends StatefulWidget {
  const _PaletteDropTarget({
    required this.controller,
    required this.editMode,
    required this.onPaletteItemDropped,
  });

  final SplitLayoutController controller;
  final bool editMode;
  final SplitNode Function(PaletteItem item) onPaletteItemDropped;

  @override
  State<_PaletteDropTarget> createState() => _PaletteDropTargetState();
}

class _PaletteDropTargetState extends State<_PaletteDropTarget> {
  @override
  Widget build(BuildContext context) {
    return EditableMultiSplitView(
      controller: widget.controller,
      config: EditableMultiSplitViewConfig(
        dividerThickness: 6,
        paneConfig: DraggablePaneConfig(
          dragFeedbackOpacity: 0.8,
          dragFeedbackScale: 0.95,
          previewStyle: const DropPreviewStyle(
            splitColor: Color(0x4D2196F3),
            replaceColor: Color(0x4D4CAF50),
            borderWidth: 3,
            borderRadius: 8,
          ),
        ),
      ),
      onNodeDropped: (draggedItem, preview, targetNode) {
        // This handles internal drag-drop between existing panes
        // Return null to use default behavior
        return null;
      },
    );
  }
}

/// A sample panel widget used in the layout
class PanelWidget extends StatelessWidget {
  const PanelWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
  });

  final String title;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? color.withValues(alpha: 0.2) : color.withValues(alpha: 0.1);
    final borderColor = color.withValues(alpha: 0.3);

    return _PanelDropTarget(
      title: title,
      icon: icon,
      color: color,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.3 : 0.15),
                border: Border(
                  bottom: BorderSide(color: borderColor),
                ),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : _darken(color),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.drag_indicator,
                    size: 18,
                    color: color.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 48,
                      color: color.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        color: color.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Drag to rearrange',
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _darken(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}

/// Drop target wrapper for panels to accept palette items
class _PanelDropTarget extends StatefulWidget {
  const _PanelDropTarget({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  State<_PanelDropTarget> createState() => _PanelDropTargetState();
}

class _PanelDropTargetState extends State<_PanelDropTarget> {
  bool _isHovering = false;
  Offset? _hoverPosition;
  Size? _size;

  DropZone? get _currentZone {
    if (_hoverPosition == null || _size == null) return null;
    const detector = HoverZoneDetector();
    return detector.detectZone(_hoverPosition!, _size!);
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<PaletteItem>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: _onAccept,
      onMove: _onMove,
      onLeave: (_) => setState(() {
        _isHovering = false;
        _hoverPosition = null;
      }),
      builder: (context, candidateData, rejectedData) {
        return LayoutBuilder(
          builder: (context, constraints) {
            _size = Size(constraints.maxWidth, constraints.maxHeight);
            return Stack(
              fit: StackFit.expand,
              children: [
                widget.child,
                if (_isHovering && candidateData.isNotEmpty)
                  _buildDropPreview(),
              ],
            );
          },
        );
      },
    );
  }

  void _onMove(DragTargetDetails<PaletteItem> details) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    setState(() {
      _isHovering = true;
      _hoverPosition = box.globalToLocal(details.offset);
    });
  }

  void _onAccept(DragTargetDetails<PaletteItem> details) {
    final zone = _currentZone;
    if (zone == null) return;

    // Find the controller from context
    final controller = _findController(context);
    if (controller == null) return;

    // Find this panel's node in the tree
    final rootNode = controller.rootNode;
    final panelPath = _findPanelPath(rootNode, widget.title);
    if (panelPath == null) return;

    // Create new node from palette item
    final item = details.data;
    final newNodeId = '${item.type}_${DateTime.now().millisecondsSinceEpoch}';
    final newNode = SplitNode.leaf(
      id: newNodeId,
      widgetBuilder: (_) => PanelWidget(
        title: item.title,
        icon: item.icon,
        color: item.color,
      ),
    );

    // Apply the drop based on zone
    if (zone == DropZone.center) {
      // Replace this panel
      controller.updateRootNode(
        rootNode.replaceAtPath(panelPath, newNode),
      );
    } else {
      // Split this panel
      final axis = zone.isHorizontalSplit
          ? SplitAxis.horizontal
          : SplitAxis.vertical;
      final insertBefore = zone == DropZone.left || zone == DropZone.top;

      controller.updateRootNode(
        rootNode.wrapInBranch(panelPath, axis, newNode, insertBefore),
      );
    }

    setState(() {
      _isHovering = false;
      _hoverPosition = null;
    });
  }

  SplitLayoutController? _findController(BuildContext context) {
    // Walk up the tree to find EditableMultiSplitView
    SplitLayoutController? controller;
    context.visitAncestorElements((element) {
      if (element.widget is EditableMultiSplitView) {
        controller = (element.widget as EditableMultiSplitView).controller;
        return false;
      }
      return true;
    });
    return controller;
  }

  List<int>? _findPanelPath(SplitNode node, String title, [List<int>? path]) {
    path ??= [];

    if (node.isLeaf) {
      // Check if this node's widget builder creates a panel with matching title
      // We need to match by examining the node
      return path;
    }

    for (var i = 0; i < node.children.length; i++) {
      final childPath = _findPanelPath(node.children[i], title, [...path, i]);
      if (childPath != null) {
        // For simplicity, return the first leaf path
        // In production, you'd want more sophisticated matching
      }
    }

    return null;
  }

  Widget _buildDropPreview() {
    final zone = _currentZone;
    if (zone == null || _size == null) return const SizedBox.shrink();

    const detector = HoverZoneDetector();
    final previewRect = detector.calculatePreviewRect(
      zone,
      Offset.zero & _size!,
    );

    final isReplace = zone == DropZone.center;
    final color = isReplace
        ? const Color(0x4D4CAF50) // Green for replace
        : const Color(0x4D2196F3); // Blue for split
    final borderColor = isReplace
        ? const Color(0x804CAF50)
        : const Color(0x802196F3);

    return Positioned.fromRect(
      rect: previewRect,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 3),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isReplace ? Icons.swap_horiz : Icons.add,
                  color: isReplace ? Colors.green : Colors.blue,
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  isReplace ? 'Replace' : 'Split ${zone.name}',
                  style: TextStyle(
                    color: isReplace ? Colors.green : Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
