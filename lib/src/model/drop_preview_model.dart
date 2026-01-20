import 'dart:ui';

import 'package:drag_split_layout/src/model/split_node.dart';
import 'package:flutter/foundation.dart';

/// The type of drop action that will occur.
enum DropAction {
  /// The dragged item will be inserted as a split (new sibling)
  split,

  /// The dragged item will replace the target content
  replace,
}

/// The zone where the pointer is hovering within a pane.
enum DropZone {
  left,
  right,
  top,
  bottom,
  center;

  /// Whether this zone results in a horizontal split
  bool get isHorizontalSplit => this == left || this == right;

  /// Whether this zone results in a vertical split
  bool get isVerticalSplit => this == top || this == bottom;

  /// Whether this zone is an edge zone (results in split)
  bool get isEdge => this != center;

  /// Returns the split axis for this zone
  SplitAxis? get splitAxis {
    if (isHorizontalSplit) return SplitAxis.horizontal;
    if (isVerticalSplit) return SplitAxis.vertical;
    return null;
  }

  /// Whether the new item should be inserted before the target
  bool get insertBefore => this == left || this == top;
}

/// Represents the preview state during a drag operation.
///
/// This model contains all the information needed to display the drop preview
/// and to execute the actual drop operation.
@immutable
class DropPreviewModel {
  /// Creates a new drop preview model.
  const DropPreviewModel({
    required this.targetNodeId,
    required this.targetNodePath,
    required this.zone,
    required this.previewRect,
    required this.paneRect,
  });

  /// The ID of the target node where the item will be dropped.
  final String targetNodeId;

  /// The path to the target node in the layout tree.
  final List<int> targetNodePath;

  /// The zone where the pointer is hovering.
  final DropZone zone;

  /// The rectangle representing the preview area (in local coordinates).
  final Rect previewRect;

  /// The full rectangle of the target pane (for reference).
  final Rect paneRect;

  /// The action that will be performed on drop.
  DropAction get action => zone.isEdge ? DropAction.split : DropAction.replace;

  /// The split direction if this is a split action.
  SplitAxis? get splitDirection => zone.splitAxis;

  /// Whether the new item will be inserted before the target (for splits).
  bool get insertBefore => zone.insertBefore;

  /// Creates a copy of this model with the specified changes.
  DropPreviewModel copyWith({
    String? targetNodeId,
    List<int>? targetNodePath,
    DropZone? zone,
    Rect? previewRect,
    Rect? paneRect,
  }) {
    return DropPreviewModel(
      targetNodeId: targetNodeId ?? this.targetNodeId,
      targetNodePath: targetNodePath ?? this.targetNodePath,
      zone: zone ?? this.zone,
      previewRect: previewRect ?? this.previewRect,
      paneRect: paneRect ?? this.paneRect,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DropPreviewModel &&
          runtimeType == other.runtimeType &&
          targetNodeId == other.targetNodeId &&
          zone == other.zone &&
          previewRect == other.previewRect &&
          paneRect == other.paneRect &&
          listEquals(targetNodePath, other.targetNodePath);

  @override
  int get hashCode => Object.hash(
        targetNodeId,
        zone,
        previewRect,
        paneRect,
        Object.hashAll(targetNodePath),
      );

  @override
  String toString() {
    return 'DropPreviewModel('
        'targetNodeId: $targetNodeId, '
        'zone: $zone, '
        'action: $action, '
        'previewRect: $previewRect)';
  }
}
