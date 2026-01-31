import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class ScriptureCard extends StatelessWidget {
  const ScriptureCard({
    super.key,
    required this.child,
    this.backgroundImage,
    this.padding = const EdgeInsets.all(12),
    this.borderRadius = 12,
    this.borderColor,
    this.backgroundColor = const Color(0xFF1E1A12),
    this.showShadow = true,
  });

  final Widget child;
  final ui.Image? backgroundImage;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? borderColor;
  final Color backgroundColor;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor = borderColor ?? const Color(0xFF5C4B32);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: resolvedBorderColor, width: 1.2),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            if (backgroundImage != null)
              Positioned.fill(
                child: RawImage(
                  image: backgroundImage,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
