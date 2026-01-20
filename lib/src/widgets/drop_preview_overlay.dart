import 'package:drag_split_layout/src/model/drop_preview_model.dart';
import 'package:flutter/material.dart';

/// Configuration for the drop preview appearance.
class DropPreviewStyle {
  /// Creates a new drop preview style.
  const DropPreviewStyle({
    this.splitColor = const Color(0x4D2196F3),
    this.replaceColor = const Color(0x4D4CAF50),
    this.borderWidth = 2.0,
    this.borderRadius = 4.0,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  /// Color for split preview (default: semi-transparent blue).
  final Color splitColor;

  /// Color for replace preview (default: semi-transparent green).
  final Color replaceColor;

  /// Width of the preview border.
  final double borderWidth;

  /// Border radius of the preview rectangle.
  final double borderRadius;

  /// Duration of the preview animation.
  final Duration animationDuration;

  /// Returns the appropriate color based on the drop action.
  Color colorForAction(DropAction action) {
    return action == DropAction.split ? splitColor : replaceColor;
  }

  /// Returns a slightly more opaque version for the border.
  Color borderColorForAction(DropAction action) {
    final baseColor = colorForAction(action);
    final newAlpha = (baseColor.a * 1.5).clamp(0.0, 1.0);
    return baseColor.withValues(alpha: newAlpha);
  }
}

/// Widget that displays the drop preview overlay.
///
/// This widget should be positioned over the pane content using a Stack.
/// It animates smoothly between preview states.
class DropPreviewOverlay extends StatelessWidget {
  /// Creates a new drop preview overlay.
  const DropPreviewOverlay({
    required this.preview, super.key,
    this.style = const DropPreviewStyle(),
  });

  /// The preview model containing position and action information.
  final DropPreviewModel? preview;

  /// The visual style configuration.
  final DropPreviewStyle style;

  @override
  Widget build(BuildContext context) {
    if (preview == null) {
      return const SizedBox.shrink();
    }

    final previewData = preview!;
    final color = style.colorForAction(previewData.action);
    final borderColor = style.borderColorForAction(previewData.action);

    return Positioned.fromRect(
      rect: previewData.previewRect,
      child: IgnorePointer(
        child: AnimatedContainer(
          duration: style.animationDuration,
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(style.borderRadius),
            border: Border.all(
              color: borderColor,
              width: style.borderWidth,
            ),
          ),
        ),
      ),
    );
  }
}

/// An animated version of the drop preview that handles its own positioning.
///
/// Use this when you want the preview to animate between positions smoothly.
class AnimatedDropPreviewOverlay extends StatefulWidget {
  /// Creates a new animated drop preview overlay.
  const AnimatedDropPreviewOverlay({
    required this.preview, super.key,
    this.style = const DropPreviewStyle(),
  });

  /// The preview model containing position and action information.
  final DropPreviewModel? preview;

  /// The visual style configuration.
  final DropPreviewStyle style;

  @override
  State<AnimatedDropPreviewOverlay> createState() =>
      _AnimatedDropPreviewOverlayState();
}

class _AnimatedDropPreviewOverlayState
    extends State<AnimatedDropPreviewOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  DropPreviewModel? _currentPreview;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.style.animationDuration,
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.preview != null) {
      _currentPreview = widget.preview;
      _targetRect = widget.preview!.previewRect;
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedDropPreviewOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.preview != oldWidget.preview) {
      if (widget.preview == null) {
        _controller.reverse().then((_) {
          if (mounted) {
            setState(() {
              _currentPreview = null;
              _targetRect = null;
            });
          }
        });
      } else {
        setState(() {
          _currentPreview = widget.preview;
          _targetRect = widget.preview!.previewRect;
        });
        if (!_controller.isCompleted) {
          _controller.forward();
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPreview == null || _targetRect == null) {
      return const SizedBox.shrink();
    }

    final color = widget.style.colorForAction(_currentPreview!.action);
    final borderColor = widget.style.borderColorForAction(_currentPreview!.action);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned.fromRect(
          rect: _targetRect!,
          child: IgnorePointer(
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: AnimatedContainer(
                duration: widget.style.animationDuration,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(widget.style.borderRadius),
                  border: Border.all(
                    color: borderColor,
                    width: widget.style.borderWidth,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
