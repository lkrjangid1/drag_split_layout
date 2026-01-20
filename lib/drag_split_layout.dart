/// A Flutter layout editor that extends multi_split_view with
/// drag-and-drop functionality and hover-based drop preview areas.
///
/// This library provides:
/// - [SplitNode]: Tree structure for representing split layouts
/// - [SplitLayoutController]: Controller for managing layout mutations
/// - [EditableMultiSplitView]: Main widget for rendering editable layouts
/// - [DraggableSplitPane]: Draggable wrapper for pane content
/// - [DropPreviewOverlay]: Visual preview during drag operations
library drag_split_layout;

import 'package:drag_split_layout/drag_split_layout.dart' show DraggableSplitPane, DropPreviewOverlay, EditableMultiSplitView, SplitLayoutController, SplitNode;
import 'package:drag_split_layout/src/drag_split_layout.dart' show DraggableSplitPane, DropPreviewOverlay, EditableMultiSplitView, SplitLayoutController, SplitNode;

export 'package:multi_split_view/multi_split_view.dart'
    show Area, DividerPainter, DividerPainters, MultiSplitView, MultiSplitViewController;

export 'src/drag_split_layout.dart';
