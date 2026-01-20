# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-20

### Added

- Initial release of `drag_split_layout`
- `SplitNode` model for representing layout tree structure
  - Leaf nodes for content widgets
  - Branch nodes for nested splits
  - Configurable flex values for sizing
- `SplitLayoutController` for managing layout state
  - Edit mode toggle
  - Node manipulation methods (replace, insert, remove, wrap)
  - Path-based node lookup
  - Change notification support
- `EditableMultiSplitView` widget for rendering editable layouts
  - Drag-and-drop pane rearrangement
  - Visual drop preview overlays
  - Customizable dividers
- `SimpleEditableLayout` for quick layout creation
- `DraggableSplitPane` wrapper for making panes draggable
- `DropTargetPane` for drop-only targets
- Drop zone detection with 5 zones:
  - Left, right, top, bottom (split operations)
  - Center (replace operation)
- Visual drop preview with customizable styling
  - Blue highlight for split operations
  - Green highlight for replace operations
- Mobile support with long-press dragging
- Comprehensive configuration options
  - `EditableMultiSplitViewConfig`
  - `DraggablePaneConfig`
  - `DropPreviewStyle`
- Full example application demonstrating all features

### Dependencies

- `multi_split_view: ^3.1.0` for resizable split view functionality
