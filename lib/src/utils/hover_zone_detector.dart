import 'dart:ui';

import 'package:drag_split_layout/src/model/drop_preview_model.dart';

/// Utility class for detecting which drop zone the pointer is in
/// and calculating preview rectangles.
class HoverZoneDetector {
  /// Creates a new hover zone detector.
  const HoverZoneDetector({
    this.edgeThreshold = 0.20,
    this.previewSizeRatio = 0.5,
  });

  /// The threshold (as a fraction of dimension) for detecting edge zones.
  /// A value of 0.20 means 20% from each edge triggers a split preview.
  final double edgeThreshold;

  /// The size ratio of the preview area relative to the split portion.
  /// A value of 0.5 means the preview takes up half of the split area.
  final double previewSizeRatio;

  /// Detects the drop zone based on pointer position within the pane.
  ///
  /// [localPosition] is the pointer position relative to the pane.
  /// [paneSize] is the size of the target pane.
  DropZone detectZone(Offset localPosition, Size paneSize) {
    final relativeX = localPosition.dx / paneSize.width;
    final relativeY = localPosition.dy / paneSize.height;

    // Check edge zones first
    final isNearLeft = relativeX < edgeThreshold;
    final isNearRight = relativeX > (1 - edgeThreshold);
    final isNearTop = relativeY < edgeThreshold;
    final isNearBottom = relativeY > (1 - edgeThreshold);

    // Calculate distances to each edge for priority
    final distanceToLeft = relativeX;
    final distanceToRight = 1 - relativeX;
    final distanceToTop = relativeY;
    final distanceToBottom = 1 - relativeY;

    // Find the minimum distance among all edges
    final minHorizontal =
        distanceToLeft < distanceToRight ? distanceToLeft : distanceToRight;
    final minVertical =
        distanceToTop < distanceToBottom ? distanceToTop : distanceToBottom;

    // If we're in an edge zone, determine which one
    if (isNearLeft || isNearRight || isNearTop || isNearBottom) {
      // Prefer the closer edge
      if (minHorizontal < minVertical) {
        return distanceToLeft < distanceToRight ? DropZone.left : DropZone.right;
      } else {
        return distanceToTop < distanceToBottom ? DropZone.top : DropZone.bottom;
      }
    }

    // Center zone
    return DropZone.center;
  }

  /// Calculates the preview rectangle for a given zone.
  ///
  /// [zone] is the detected drop zone.
  /// [paneRect] is the rectangle of the target pane (usually Offset.zero & size).
  Rect calculatePreviewRect(DropZone zone, Rect paneRect) {
    final width = paneRect.width;
    final height = paneRect.height;
    final previewWidth = width * previewSizeRatio;
    final previewHeight = height * previewSizeRatio;

    switch (zone) {
      case DropZone.left:
        return Rect.fromLTWH(
          paneRect.left,
          paneRect.top,
          previewWidth,
          height,
        );
      case DropZone.right:
        return Rect.fromLTWH(
          paneRect.right - previewWidth,
          paneRect.top,
          previewWidth,
          height,
        );
      case DropZone.top:
        return Rect.fromLTWH(
          paneRect.left,
          paneRect.top,
          width,
          previewHeight,
        );
      case DropZone.bottom:
        return Rect.fromLTWH(
          paneRect.left,
          paneRect.bottom - previewHeight,
          width,
          previewHeight,
        );
      case DropZone.center:
        // For center/replace, show the entire pane with slight inset
        return paneRect.deflate(4);
    }
  }

  /// Creates a complete drop preview model from the given inputs.
  ///
  /// [localPosition] is the pointer position relative to the pane.
  /// [paneSize] is the size of the target pane.
  /// [targetNodeId] is the ID of the node being hovered over.
  /// [targetNodePath] is the path to the target node in the tree.
  DropPreviewModel createPreview({
    required Offset localPosition,
    required Size paneSize,
    required String targetNodeId,
    required List<int> targetNodePath,
  }) {
    final zone = detectZone(localPosition, paneSize);
    final paneRect = Offset.zero & paneSize;
    final previewRect = calculatePreviewRect(zone, paneRect);

    return DropPreviewModel(
      targetNodeId: targetNodeId,
      targetNodePath: targetNodePath,
      zone: zone,
      previewRect: previewRect,
      paneRect: paneRect,
    );
  }
}
