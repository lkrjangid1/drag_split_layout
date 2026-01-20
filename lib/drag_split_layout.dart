/// A Flutter package for creating resizable split-pane layouts with
/// drag-and-drop support.
///
/// Build IDE-like interfaces where users can rearrange, split, and replace
/// panes with intuitive gestures and visual drop previews.
///
/// ## Main Components
///
/// - `SplitNode`: Tree structure for representing split layouts
/// - `SplitLayoutController`: Controller for managing layout state
/// - `EditableMultiSplitView`: Main widget for rendering editable layouts
/// - `SimpleEditableLayout`: Simplified widget for basic layouts
/// - `DraggableSplitPane`: Draggable wrapper for pane content
/// - `DropTargetPane`: Drop target wrapper without drag capability
///
/// ## Quick Start
///
/// ```dart
/// final controller = SplitLayoutController(
///   rootNode: SplitNode.branch(
///     id: 'root',
///     axis: SplitAxis.horizontal,
///     children: [
///       SplitNode.leaf(id: 'left', widgetBuilder: (_) => LeftPanel()),
///       SplitNode.leaf(id: 'right', widgetBuilder: (_) => RightPanel()),
///     ],
///   ),
/// );
///
/// EditableMultiSplitView(controller: controller)
/// ```
///
/// ## Features
///
/// - Drag panes to rearrange within the layout
/// - Drop on edges to split panes (left, right, top, bottom)
/// - Drop in center to replace pane content
/// - Visual preview during drag (blue for split, green for replace)
/// - Resizable panes with draggable dividers
/// - Edit mode toggle for enabling/disabling drag-and-drop
/// - Mobile support with long-press dragging
library drag_split_layout;

export 'package:multi_split_view/multi_split_view.dart'
    show
        Area,
        DividerPainter,
        DividerPainters,
        MultiSplitView,
        MultiSplitViewController;

export 'src/drag_split_layout.dart';
