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
    this.textColor,
  });

  final Widget child;
  final ui.Image? backgroundImage;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? borderColor;
  final Color backgroundColor;
  final bool showShadow;
  final Color? textColor;

  static const Color ink = Color(0xFF1E140A);
  static const Color inkMuted = Color(0xFF4D3A26);
  static const Color inkFaint = Color(0xFF6B5843);
  static const Color inkStrong = Color(0xFF24180C);

  @override
  Widget build(BuildContext context) {
    final resolvedBorderColor = borderColor ?? const Color(0xFF5C4B32);
    final resolvedTextColor =
        textColor ?? (backgroundImage != null ? ink : null);
    Widget content = child;
    if (resolvedTextColor != null) {
      final baseStyle =
          Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: resolvedTextColor) ??
          TextStyle(color: resolvedTextColor);
      content = DefaultTextStyle.merge(
        style: baseStyle,
        child: IconTheme.merge(
          data: IconThemeData(color: resolvedTextColor),
          child: content,
        ),
      );
    }
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
            Padding(padding: padding, child: content),
          ],
        ),
      ),
    );
  }
}

Color scriptureTextColor(ui.Image? backgroundImage) {
  return backgroundImage != null ? ScriptureCard.ink : Colors.white70;
}

Color scriptureMutedTextColor(ui.Image? backgroundImage) {
  return backgroundImage != null ? ScriptureCard.inkMuted : Colors.white54;
}

Color scriptureFaintTextColor(ui.Image? backgroundImage) {
  return backgroundImage != null ? ScriptureCard.inkFaint : Colors.white60;
}

Color scriptureStrongTextColor(ui.Image? backgroundImage) {
  return backgroundImage != null ? ScriptureCard.inkStrong : Colors.white;
}
