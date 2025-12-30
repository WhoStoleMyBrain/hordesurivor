import 'package:flutter/material.dart';

class HomeBaseOverlay extends StatelessWidget {
  const HomeBaseOverlay({super.key});

  static const String overlayKey = 'home_base_overlay';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Home Base — walk into the portal to choose an area.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
