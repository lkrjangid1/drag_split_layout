# Drag Split Layout

[![pub package](https://img.shields.io/pub/v/drag_split_layout.svg)](https://pub.dev/packages/drag_split_layout)
[![style: very good analysis](https://img.shields.io/badge/style-very_good_analysis-B22C89.svg)](https://pub.dev/packages/very_good_analysis)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

A Flutter package for creating resizable split-pane layouts with drag-and-drop support. Build IDE-like interfaces where users can rearrange, split, and replace panes with intuitive gestures and visual drop previews.

## Features

- **Drag and Drop Rearrangement** - Drag panes to rearrange them within the layout
- **Split Zones** - Drop on edges (left, right, top, bottom) to split panes
- **Replace Zones** - Drop in center to replace existing panes
- **Visual Drop Preview** - Blue preview for split operations, green for replace
- **Resizable Panes** - Drag dividers to resize panes (powered by multi_split_view)
- **Edit Mode Toggle** - Enable/disable drag-and-drop functionality
- **Mobile Support** - Long-press dragging on touch devices
- **Customizable Styling** - Configure colors, borders, animations, and more

<img src='https://github.com/user-attachments/assets/65beced3-22c4-4424-a0e4-e0a8c6ed0a63'>

## Installation

Add `drag_split_layout` to your `pubspec.yaml`:

```yaml
dependencies:
  drag_split_layout: ^0.1.0
```

Then run:

```sh
flutter pub get
```

## Quick Start

### Basic Usage

```dart
import 'package:drag_split_layout/drag_split_layout.dart';
import 'package:flutter/material.dart';

class MyLayoutEditor extends StatefulWidget {
  @override
  State<MyLayoutEditor> createState() => _MyLayoutEditorState();
}

class _MyLayoutEditorState extends State<MyLayoutEditor> {
  late SplitLayoutController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SplitLayoutController(
      rootNode: SplitNode.branch(
        id: 'root',
        axis: SplitAxis.horizontal,
        children: [
          SplitNode.leaf(
            id: 'panel_1',
            widgetBuilder: (_) => Container(
              color: Colors.blue[100],
              child: const Center(child: Text('Panel 1')),
            ),
          ),
          SplitNode.leaf(
            id: 'panel_2',
            widgetBuilder: (_) => Container(
              color: Colors.green[100],
              child: const Center(child: Text('Panel 2')),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EditableMultiSplitView(
      controller: _controller,
    );
  }
}
```

### Simple Layout (Without Manual Tree Construction)

```dart
SimpleEditableLayout(
  initialAxis: SplitAxis.horizontal,
  editMode: true,
  children: [
    Container(color: Colors.red[100], child: Text('Panel 1')),
    Container(color: Colors.blue[100], child: Text('Panel 2')),
    Container(color: Colors.green[100], child: Text('Panel 3')),
  ],
)
```

## Core Concepts

### SplitNode

The layout is represented as a tree of `SplitNode` objects:

- **Leaf Node** - Contains a widget (the actual content)
- **Branch Node** - Contains child nodes arranged along an axis

```dart
// Leaf node with content
SplitNode.leaf(
  id: 'editor',
  flex: 2.0, // Takes 2x space relative to siblings
  widgetBuilder: (context) => MyEditorWidget(),
)

// Branch node with children
SplitNode.branch(
  id: 'main',
  axis: SplitAxis.horizontal, // or SplitAxis.vertical
  children: [leafNode1, leafNode2],
)
```

### SplitLayoutController

Manages the layout tree and edit mode:

```dart
final controller = SplitLayoutController(rootNode: myRootNode);

// Toggle edit mode
controller.editMode = true; // Enable drag-and-drop
controller.editMode = false; // Disable drag-and-drop

// Update the layout
controller.updateRootNode(newRootNode);

// Find nodes
final path = controller.findPathById('panel_1');
final node = controller.getNodeAtPath([0, 1]);

// Listen to changes
controller.addListener(() {
  print('Layout changed!');
});
```

### Drop Zones

When dragging a pane over another, the drop zone is determined by pointer position:

| Zone | Position | Action |
|------|----------|--------|
| Left | Left 20% of pane | Split horizontally, insert left |
| Right | Right 20% of pane | Split horizontally, insert right |
| Top | Top 20% of pane | Split vertically, insert above |
| Bottom | Bottom 20% of pane | Split vertically, insert below |
| Center | Middle 60% of pane | Replace the target pane |

## Configuration

### EditableMultiSplitViewConfig

```dart
EditableMultiSplitView(
  controller: _controller,
  config: EditableMultiSplitViewConfig(
    dividerThickness: 8.0,
    antiAliasingWorkaround: true,
    paneConfig: DraggablePaneConfig(
      dragFeedbackOpacity: 0.7,
      dragFeedbackScale: 0.9,
      useLongPressOnMobile: true,
      longPressDuration: Duration(milliseconds: 300),
      previewStyle: DropPreviewStyle(
        splitColor: Color(0x4D2196F3), // Blue for split
        replaceColor: Color(0x4D4CAF50), // Green for replace
        borderWidth: 2.0,
        borderRadius: 4.0,
        animationDuration: Duration(milliseconds: 150),
      ),
    ),
  ),
)
```

### Custom Drop Handling

```dart
EditableMultiSplitView(
  controller: _controller,
  onNodeDropped: (draggedItem, preview, targetNode) {
    // Return a custom node, or null to cancel the drop
    if (preview.zone == DropZone.center) {
      // Custom handling for replace operations
      return SplitNode.leaf(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        widgetBuilder: (_) => MyCustomWidget(),
      );
    }
    // Return null to use default behavior
    return null;
  },
)
```

## Advanced Usage

### External Drag Sources

Accept drops from external drag sources (like a component palette):

```dart
class PaletteItem {
  final String type;
  final String title;
  final IconData icon;
}

// In your palette widget
Draggable<PaletteItem>(
  data: PaletteItem(type: 'editor', title: 'Code Editor', icon: Icons.code),
  dragAnchorStrategy: pointerDragAnchorStrategy,
  feedback: Material(
    child: Container(
      padding: EdgeInsets.all(12),
      child: Text('Code Editor'),
    ),
  ),
  child: ListTile(title: Text('Code Editor')),
)

// Handle the drop in your panel widget using DragTarget<PaletteItem>
```

### Nested Layouts

Create complex nested layouts:

```dart
SplitNode.branch(
  id: 'root',
  axis: SplitAxis.horizontal,
  children: [
    // Left sidebar
    SplitNode.leaf(id: 'sidebar', flex: 0.5, widgetBuilder: ...),
    // Main area with nested vertical split
    SplitNode.branch(
      id: 'main',
      axis: SplitAxis.vertical,
      flex: 2.0,
      children: [
        SplitNode.leaf(id: 'editor', flex: 2.0, widgetBuilder: ...),
        SplitNode.leaf(id: 'terminal', flex: 1.0, widgetBuilder: ...),
      ],
    ),
    // Right panel
    SplitNode.leaf(id: 'preview', flex: 1.0, widgetBuilder: ...),
  ],
)
```

### Programmatic Layout Manipulation

```dart
// Get current root node
final root = controller.rootNode;

// Replace a node at path
final newRoot = root.replaceAtPath([0, 1], newNode);
controller.updateRootNode(newRoot);

// Insert a node
final withInserted = root.insertAtPath([0], 1, newNode);
controller.updateRootNode(withInserted);

// Remove a node
final withRemoved = root.removeAtPath([0, 2]);
controller.updateRootNode(withRemoved);

// Wrap a node in a new branch (split it)
final wrapped = root.wrapInBranch(
  [0], // path to node
  SplitAxis.vertical, // new split axis
  newSiblingNode, // node to add
  true, // insert before (true) or after (false)
);
controller.updateRootNode(wrapped);
```

## API Reference

### Main Classes

| Class | Description |
|-------|-------------|
| `SplitNode` | Represents a node in the layout tree |
| `SplitLayoutController` | Manages layout state and edit mode |
| `EditableMultiSplitView` | Main widget for rendering the layout |
| `SimpleEditableLayout` | Simplified widget for basic layouts |
| `DraggableSplitPane` | Wrapper that makes panes draggable |
| `DropTargetPane` | Drop target without being draggable |

### Models

| Class | Description |
|-------|-------------|
| `DragItemModel` | Data transferred during drag operations |
| `DropPreviewModel` | Information about the current drop preview |
| `DropZone` | Enum for drop zones (left, right, top, bottom, center) |
| `DropAction` | Enum for drop actions (split, replace) |
| `SplitAxis` | Enum for split direction (horizontal, vertical) |

### Configuration Classes

| Class | Description |
|-------|-------------|
| `EditableMultiSplitViewConfig` | Configuration for the main widget |
| `DraggablePaneConfig` | Configuration for draggable behavior |
| `DropPreviewStyle` | Styling for drop preview overlays |

## Example

Check out the [example](https://github.com/aspect-dev/drag_split_layout/tree/main/example) directory for a complete demo application featuring:

- Resizable split panes
- Drag-and-drop rearrangement
- Component palette for adding new panels
- Edit mode toggle
- Multiple panel types

Run the example:

```sh
cd example
flutter run
```

## Requirements

- Flutter SDK: ^3.24.0
- Dart SDK: ^3.5.0

## Dependencies

- [multi_split_view](https://pub.dev/packages/multi_split_view) - For resizable split view functionality

## Contributing

Contributions are welcome! Please read our [contributing guidelines](CONTRIBUTING.md) before submitting a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
