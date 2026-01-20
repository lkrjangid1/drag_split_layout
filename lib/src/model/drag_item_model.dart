import 'package:flutter/foundation.dart';

/// Represents the data associated with a draggable pane.
///
/// This model is passed as the drag data when a pane is being dragged,
/// containing all information needed to identify and relocate the pane.
@immutable
class DragItemModel {
  /// Creates a new drag item model.
  const DragItemModel({
    required this.id,
    required this.widgetType,
    required this.originalPath,
  });

  /// The unique identifier of the widget being dragged.
  final String id;

  /// A string identifier for the type of widget (e.g., 'panel', 'editor', 'terminal').
  /// This can be used for type-specific drop logic or visual feedback.
  final String widgetType;

  /// The original path to this node in the layout tree.
  /// Used to remove the node from its original location after a successful drop.
  final List<int> originalPath;

  /// Creates a copy of this model with the specified changes.
  DragItemModel copyWith({
    String? id,
    String? widgetType,
    List<int>? originalPath,
  }) {
    return DragItemModel(
      id: id ?? this.id,
      widgetType: widgetType ?? this.widgetType,
      originalPath: originalPath ?? this.originalPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DragItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          widgetType == other.widgetType &&
          listEquals(originalPath, other.originalPath);

  @override
  int get hashCode => Object.hash(id, widgetType, Object.hashAll(originalPath));

  @override
  String toString() {
    return 'DragItemModel(id: $id, widgetType: $widgetType, '
        'originalPath: $originalPath)';
  }
}
