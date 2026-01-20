import 'dart:ui';

import 'package:drag_split_layout/src/model/drag_item_model.dart';
import 'package:drag_split_layout/src/model/drop_preview_model.dart';
import 'package:drag_split_layout/src/model/split_node.dart';
import 'package:drag_split_layout/src/utils/hover_zone_detector.dart';
import 'package:flutter/foundation.dart';

/// Controller responsible for managing the split layout tree structure
/// and handling drag-and-drop operations.
///
/// This controller extends [ChangeNotifier] to allow widgets to rebuild
/// when the layout changes.
class SplitLayoutController extends ChangeNotifier {
  /// Creates a new split layout controller.
  ///
  /// [rootNode] is the initial root of the layout tree.
  /// [zoneDetector] is used for detecting hover zones (defaults to standard detector).
  SplitLayoutController({
    required SplitNode rootNode,
    HoverZoneDetector? zoneDetector,
  })  : _rootNode = rootNode,
        _zoneDetector = zoneDetector ?? const HoverZoneDetector();

  final HoverZoneDetector _zoneDetector;

  SplitNode _rootNode;
  DropPreviewModel? _preview;
  DragItemModel? _activeDragItem;
  bool _editMode = true;

  /// The current root node of the layout tree.
  SplitNode get rootNode => _rootNode;

  /// The current drop preview, or null if not previewing.
  DropPreviewModel? get preview => _preview;

  /// The item currently being dragged, or null if no drag in progress.
  DragItemModel? get activeDragItem => _activeDragItem;

  /// Whether edit mode is enabled (drag, drop, preview enabled).
  bool get editMode => _editMode;

  /// Sets the edit mode flag.
  set editMode(bool value) {
    if (_editMode != value) {
      _editMode = value;
      if (!value) {
        clearPreview();
        _activeDragItem = null;
      }
      notifyListeners();
    }
  }

  /// Updates the root node directly.
  ///
  /// Use this for external updates to the layout structure.
  void updateRootNode(SplitNode newRoot) {
    _rootNode = newRoot;
    notifyListeners();
  }

  /// Called when a drag operation starts.
  void onDragStart(DragItemModel item) {
    if (!_editMode) return;
    _activeDragItem = item;
    notifyListeners();
  }

  /// Called when a drag operation ends (regardless of drop success).
  void onDragEnd() {
    _activeDragItem = null;
    clearPreview();
    notifyListeners();
  }

  /// Updates the preview based on pointer hover position.
  ///
  /// [localPosition] is the pointer position relative to the target pane.
  /// [paneSize] is the size of the target pane.
  /// [targetNodeId] is the ID of the node being hovered over.
  /// [targetNodePath] is the path to the target node in the tree.
  void onHoverUpdate({
    required Offset localPosition,
    required Size paneSize,
    required String targetNodeId,
    required List<int> targetNodePath,
  }) {
    if (!_editMode || _activeDragItem == null) return;

    // Don't show preview if hovering over the item being dragged
    if (_activeDragItem!.id == targetNodeId) {
      clearPreview();
      return;
    }

    final newPreview = _zoneDetector.createPreview(
      localPosition: localPosition,
      paneSize: paneSize,
      targetNodeId: targetNodeId,
      targetNodePath: targetNodePath,
    );

    // Only notify if preview actually changed
    if (_preview != newPreview) {
      _preview = newPreview;
      notifyListeners();
    }
  }

  /// Clears the current drop preview.
  void clearPreview() {
    if (_preview != null) {
      _preview = null;
      notifyListeners();
    }
  }

  /// Executes a drop operation based on the current preview.
  ///
  /// [draggedItem] is the item being dropped.
  /// [newNodeBuilder] is a function that creates the new node to insert.
  ///
  /// Returns true if the drop was successful, false otherwise.
  bool onDrop({
    required DragItemModel draggedItem,
    required SplitNode Function() newNodeBuilder,
  }) {
    if (!_editMode || _preview == null) return false;

    final preview = _preview!;

    // Don't drop on self
    if (draggedItem.id == preview.targetNodeId) {
      clearPreview();
      return false;
    }

    final newNode = newNodeBuilder();

    switch (preview.action) {
      case DropAction.split:
        _applySplitDrop(
          draggedItem: draggedItem,
          preview: preview,
          newNode: newNode,
        );
      case DropAction.replace:
        _applyReplaceDrop(
          draggedItem: draggedItem,
          preview: preview,
          newNode: newNode,
        );
    }

    clearPreview();
    _activeDragItem = null;
    notifyListeners();
    return true;
  }

  /// Applies a split drop operation.
  void _applySplitDrop({
    required DragItemModel draggedItem,
    required DropPreviewModel preview,
    required SplitNode newNode,
  }) {
    // First, wrap the target in a branch with the new node
    var updatedRoot = _rootNode.wrapInBranch(
      preview.targetNodePath,
      preview.splitDirection!,
      newNode.copyWith(flex: 1),
      preview.insertBefore,
    );

    // Then remove the original node if it was moved (not a new item)
    if (draggedItem.originalPath.isNotEmpty) {
      // Adjust the path if needed after the wrap operation
      final adjustedPath = _adjustPathAfterWrap(
        originalPath: draggedItem.originalPath,
        wrapPath: preview.targetNodePath,
        insertBefore: preview.insertBefore,
      );

      final withRemoval = updatedRoot.removeAtPath(adjustedPath);
      if (withRemoval != null) {
        updatedRoot = withRemoval;
      }
    }

    _rootNode = updatedRoot;
  }

  /// Applies a replace drop operation.
  void _applyReplaceDrop({
    required DragItemModel draggedItem,
    required DropPreviewModel preview,
    required SplitNode newNode,
  }) {
    // Get the target node to preserve its flex
    final targetNode = _rootNode.nodeAtPath(preview.targetNodePath);
    final preservedFlex = targetNode?.flex ?? 1.0;

    // Replace the target with the new node
    var updatedRoot = _rootNode.replaceAtPath(
      preview.targetNodePath,
      newNode.copyWith(flex: preservedFlex),
    );

    // Remove the original node if it was moved (not a new item)
    if (draggedItem.originalPath.isNotEmpty) {
      // Check if the replacement affected the original path
      final adjustedPath = _adjustPathAfterReplace(
        originalPath: draggedItem.originalPath,
        replacePath: preview.targetNodePath,
      );

      // Only remove if the paths are different
      if (!listEquals(adjustedPath, preview.targetNodePath)) {
        final withRemoval = updatedRoot.removeAtPath(adjustedPath);
        if (withRemoval != null) {
          updatedRoot = withRemoval;
        }
      }
    }

    _rootNode = updatedRoot;
  }

  /// Adjusts the original path after a wrap operation.
  List<int> _adjustPathAfterWrap({
    required List<int> originalPath,
    required List<int> wrapPath,
    required bool insertBefore,
  }) {
    if (originalPath.isEmpty) return originalPath;

    // Check if the original path is affected by the wrap
    final isDescendantOfWrap = _isDescendantOf(originalPath, wrapPath);
    final isSibling = _areSiblings(originalPath, wrapPath);

    if (isDescendantOfWrap) {
      // The wrap added a new level, so insert an index at the wrap point
      final adjustedPath = List<int>.from(originalPath);
      final insertionIndex = insertBefore ? 1 : 0;
      adjustedPath.insert(wrapPath.length, insertionIndex);
      return adjustedPath;
    }

    if (isSibling && originalPath.last > wrapPath.last) {
      // Sibling after the wrap target - no adjustment needed
      // because wrap doesn't change sibling indices
    }

    return originalPath;
  }

  /// Adjusts the original path after a replace operation.
  List<int> _adjustPathAfterReplace({
    required List<int> originalPath,
    required List<int> replacePath,
  }) {
    // Replace doesn't change the tree structure, so no adjustment needed
    return originalPath;
  }

  /// Checks if path1 is a descendant of path2.
  bool _isDescendantOf(List<int> path1, List<int> path2) {
    if (path1.length <= path2.length) return false;
    for (var i = 0; i < path2.length; i++) {
      if (path1[i] != path2[i]) return false;
    }
    return true;
  }

  /// Checks if two paths are siblings (same parent).
  bool _areSiblings(List<int> path1, List<int> path2) {
    if (path1.length != path2.length || path1.isEmpty) return false;
    for (var i = 0; i < path1.length - 1; i++) {
      if (path1[i] != path2[i]) return false;
    }
    return true;
  }

  /// Finds the path to a node by its ID.
  List<int>? findPathById(String nodeId) => _rootNode.findPath(nodeId);

  /// Gets the node at a specific path.
  SplitNode? getNodeAtPath(List<int> path) => _rootNode.nodeAtPath(path);

  /// Removes a node at the specified path.
  ///
  /// Returns true if the removal was successful.
  bool removeNode(List<int> path) {
    final result = _rootNode.removeAtPath(path);
    if (result != null) {
      _rootNode = result;
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Inserts a new node at the specified path and index.
  void insertNode(List<int> parentPath, int index, SplitNode newNode) {
    _rootNode = _rootNode.insertAtPath(parentPath, index, newNode);
    notifyListeners();
  }
}
