import 'package:flutter/material.dart';

import 'ui_scale.dart';

class FirstRunHintsOverlay extends StatelessWidget {
  const FirstRunHintsOverlay({super.key, required this.onDismiss});

  static const String overlayKey = 'first_run_hints';

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hints = [
      'Move with WASD/arrow keys or drag to steer.',
      'Skills auto-aim; stay near enemies to keep pressure.',
      'Level ups pause combat and offer new skills/items.',
      'Every item has a bonus and a tradeoff.',
    ];

    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            color: Colors.black.withValues(alpha: 0.82),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'First Run Hints',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: UiScale.fontSize(18),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final hint in hints)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• $hint',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: onDismiss,
                      child: const Text('Got it'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
