import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OptionsScreen extends StatelessWidget {
  const OptionsScreen({
    super.key,
    required this.onClose,
    required this.highContrastTelegraphs,
    required this.onHighContrastTelegraphsChanged,
  });

  static const String overlayKey = 'options_screen';

  final VoidCallback onClose;
  final ValueListenable<bool> highContrastTelegraphs;
  final ValueChanged<bool> onHighContrastTelegraphsChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Options',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<bool>(
                  valueListenable: highContrastTelegraphs,
                  builder: (context, value, _) {
                    return SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('High-contrast telegraphs'),
                      subtitle: Text(
                        'Boost enemy telegraph and aura opacity for readability.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      value: value,
                      onChanged: onHighContrastTelegraphsChanged,
                    );
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onClose,
                    child: const Text('Back'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
