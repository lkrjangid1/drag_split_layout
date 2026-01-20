import 'package:drag_split_layout/src/controller/split_layout_controller.dart';
import 'package:drag_split_layout/src/model/drag_item_model.dart';
import 'package:drag_split_layout/src/model/drop_preview_model.dart';
import 'package:drag_split_layout/src/model/split_node.dart';
import 'package:drag_split_layout/src/widgets/drop_preview_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Configuration for the draggable pane behavior and appearance.
class DraggablePaneConfig {
  /// Creates a new draggable pane configuration.
  const DraggablePaneConfig({
    this.dragFeedbackOpacity = 0.7,
    this.dragFeedbackScale = 0.9,
    this.useLongPressOnMobile = true,
    this.longPressDuration = const Duration(milliseconds: 300),
    this.previewStyle = const DropPreviewStyle(),
    this.dragHandleBuilder,
  });

  /// Opacity of the drag feedback widget.
  final double dragFeedbackOpacity;

  /// Scale of the drag feedback widget.
  final double dragFeedbackScale;

  /// Whether to use long press to initiate drag on mobile platforms.
  final bool useLongPressOnMobile;

  /// Duration required for long press to initiate drag.
  final Duration longPressDuration;

  /// Style configuration for the drop preview.
  final DropPreviewStyle previewStyle;

  /// Optional builder for a custom drag handle.
  /// If null, the entire pane is draggable.
  final Widget Function(BuildContext context)? dragHandleBuilder;
}

/// A wrapper widget that makes a pane draggable and acts as a drop target.
///
/// This widget handles:
/// - Making the child draggable (or long-press draggable on mobile)
/// - Detecting hover position for drop preview
/// - Displaying the drop preview overlay
class DraggableSplitPane extends StatefulWidget {
  /// Creates a new draggable split pane.
  const DraggableSplitPane({
    required this.nodeId,
    required this.nodePath,
    required this.widgetType,
    required this.controller,
    required this.child,
    super.key,
    this.config = const DraggablePaneConfig(),
    this.onDrop,
  });

  /// The unique identifier of this pane's node.
  final String nodeId;

  /// The path to this node in the layout tree.
  final List<int> nodePath;

  /// The type identifier for this widget (used in drag data).
  final String widgetType;

  /// The layout controller managing this pane.
  final SplitLayoutController controller;

  /// The child widget to display in this pane.
  final Widget child;

  /// Configuration for drag behavior and appearance.
  final DraggablePaneConfig config;

  /// Optional callback when a drop occurs on this pane.
  /// Return the new node to insert, or null to cancel the drop.
  final SplitNode? Function(
    DragItemModel draggedItem,
    DropPreviewModel preview,
  )? onDrop;

  @override
  State<DraggableSplitPane> createState() => _DraggableSplitPaneState();
}

class _DraggableSplitPaneState extends State<DraggableSplitPane> {
  final GlobalKey _paneKey = GlobalKey();
  bool _isDragTarget = false;

  bool get _isMobile =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  bool get _useLongPress => _isMobile && widget.config.useLongPressOnMobile;

  DragItemModel get _dragData => DragItemModel(
        id: widget.nodeId,
        widgetType: widget.widgetType,
        originalPath: widget.nodePath,
      );

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.editMode) {
      return widget.child;
    }

    return DragTarget<DragItemModel>(
      onWillAcceptWithDetails: _onWillAccept,
      onAcceptWithDetails: _onAccept,
      onMove: _onMove,
      onLeave: _onLeave,
      builder: (context, candidateData, rejectedData) {
        return _buildPaneContent(context, candidateData.isNotEmpty);
      },
    );
  }

  Widget _buildPaneContent(BuildContext context, bool isHovering) {
    final content = KeyedSubtree(
      key: _paneKey,
      child: widget.child,
    );

    Widget draggableContent;

    if (_useLongPress) {
      draggableContent = LongPressDraggable<DragItemModel>(
        data: _dragData,
        delay: widget.config.longPressDuration,
        feedback: _buildDragFeedback(context),
        childWhenDragging: _buildChildWhenDragging(),
        onDragStarted: _onDragStarted,
        onDragEnd: _onDragEnd,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        child: content,
      );
    } else {
      draggableContent = Draggable<DragItemModel>(
        data: _dragData,
        feedback: _buildDragFeedback(context),
        childWhenDragging: _buildChildWhenDragging(),
        onDragStarted: _onDragStarted,
        onDragEnd: _onDragEnd,
        dragAnchorStrategy: pointerDragAnchorStrategy,
        child: content,
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        draggableContent,
        if (_isDragTarget)
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final preview = widget.controller.preview;
              if (preview?.targetNodeId != widget.nodeId) {
                return const SizedBox.shrink();
              }
              return DropPreviewOverlay(
                preview: preview,
                style: widget.config.previewStyle,
              );
            },
          ),
      ],
    );
  }

  Widget _buildDragFeedback(BuildContext context) {
    final renderBox =
        _paneKey.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? const Size(200, 100);

    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: widget.config.dragFeedbackOpacity,
        child: Transform.scale(
          scale: widget.config.dragFeedbackScale,
          alignment: Alignment.topLeft,
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildChildWhenDragging() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _onDragStarted() {
    widget.controller.onDragStart(_dragData);
  }

  void _onDragEnd(DraggableDetails details) {
    widget.controller.onDragEnd();
  }

  bool _onWillAccept(DragTargetDetails<DragItemModel> details) {
    return details.data.id != widget.nodeId;
  }

  void _onMove(DragTargetDetails<DragItemModel> details) {
    final renderBox =
        _paneKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // details.offset is where the pointer is (due to pointerDragAnchorStrategy)
    final localPosition = renderBox.globalToLocal(details.offset);
    final size = renderBox.size;

    setState(() => _isDragTarget = true);

    widget.controller.onHoverUpdate(
      localPosition: localPosition,
      paneSize: size,
      targetNodeId: widget.nodeId,
      targetNodePath: widget.nodePath,
    );
  }

  void _onLeave(DragItemModel? data) {
    setState(() => _isDragTarget = false);

    if (widget.controller.preview?.targetNodeId == widget.nodeId) {
      widget.controller.clearPreview();
    }
  }

  void _onAccept(DragTargetDetails<DragItemModel> details) {
    setState(() => _isDragTarget = false);

    final preview = widget.controller.preview;
    if (preview == null) return;

    if (widget.onDrop != null) {
      final newNode = widget.onDrop!(details.data, preview);
      if (newNode != null) {
        widget.controller.onDrop(
          draggedItem: details.data,
          newNodeBuilder: () => newNode,
        );
      }
    } else {
      final originalNode =
          widget.controller.getNodeAtPath(details.data.originalPath);
      if (originalNode != null) {
        widget.controller.onDrop(
          draggedItem: details.data,
          newNodeBuilder: () => originalNode.copyWith(flex: 1),
        );
      }
    }
  }
}

/// A simpler version that only acts as a drop target without being draggable.
///
/// Use this for fixed elements that can receive drops but shouldn't be moved.
class DropTargetPane extends StatefulWidget {
  /// Creates a new drop target pane.
  const DropTargetPane({
    required this.nodeId,
    required this.nodePath,
    required this.controller,
    required this.child,
    required this.onDrop,
    super.key,
    this.previewStyle = const DropPreviewStyle(),
  });

  /// The unique identifier of this pane's node.
  final String nodeId;

  /// The path to this node in the layout tree.
  final List<int> nodePath;

  /// The layout controller managing this pane.
  final SplitLayoutController controller;

  /// The child widget to display in this pane.
  final Widget child;

  /// Callback when a drop occurs on this pane.
  /// Return the new node to insert, or null to cancel the drop.
  final SplitNode? Function(
    DragItemModel draggedItem,
    DropPreviewModel preview,
  ) onDrop;

  /// Style configuration for the drop preview.
  final DropPreviewStyle previewStyle;

  @override
  State<DropTargetPane> createState() => _DropTargetPaneState();
}

class _DropTargetPaneState extends State<DropTargetPane> {
  final GlobalKey _paneKey = GlobalKey();
  bool _isDragTarget = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.controller.editMode) {
      return widget.child;
    }

    return DragTarget<DragItemModel>(
      onWillAcceptWithDetails: (details) => details.data.id != widget.nodeId,
      onAcceptWithDetails: _onAccept,
      onMove: _onMove,
      onLeave: _onLeave,
      builder: (context, candidateData, rejectedData) {
        return Stack(
          key: _paneKey,
          fit: StackFit.expand,
          children: [
            widget.child,
            if (_isDragTarget)
              ListenableBuilder(
                listenable: widget.controller,
                builder: (context, _) {
                  final preview = widget.controller.preview;
                  if (preview?.targetNodeId != widget.nodeId) {
                    return const SizedBox.shrink();
                  }
                  return DropPreviewOverlay(
                    preview: preview,
                    style: widget.previewStyle,
                  );
                },
              ),
          ],
        );
      },
    );
  }

  void _onMove(DragTargetDetails<DragItemModel> details) {
    final renderBox =
        _paneKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(details.offset);
    final size = renderBox.size;

    setState(() => _isDragTarget = true);

    widget.controller.onHoverUpdate(
      localPosition: localPosition,
      paneSize: size,
      targetNodeId: widget.nodeId,
      targetNodePath: widget.nodePath,
    );
  }

  void _onLeave(DragItemModel? data) {
    setState(() => _isDragTarget = false);
    if (widget.controller.preview?.targetNodeId == widget.nodeId) {
      widget.controller.clearPreview();
    }
  }

  void _onAccept(DragTargetDetails<DragItemModel> details) {
    setState(() => _isDragTarget = false);

    final preview = widget.controller.preview;
    if (preview == null) return;

    final newNode = widget.onDrop(details.data, preview);
    if (newNode != null) {
      widget.controller.onDrop(
        draggedItem: details.data,
        newNodeBuilder: () => newNode,
      );
    }
  }
}
