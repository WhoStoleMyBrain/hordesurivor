import 'package:flutter/material.dart';

import '../game/run_summary.dart';
import 'ui_scale.dart';

class DeathScreen extends StatelessWidget {
  const DeathScreen({
    super.key,
    required this.summary,
    required this.completed,
    required this.onRestart,
    required this.onReturn,
  });

  static const String overlayKey = 'death';

  final RunSummary summary;
  final bool completed;
  final VoidCallback onRestart;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF161A22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  completed ? 'RUN COMPLETE' : 'YOU DIED',
                  style: TextStyle(
                    fontSize: 22 * UiScale.textScale,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                if (summary.areaName != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    summary.areaName!,
                    style: const TextStyle(
                      color: Colors.white70,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                _StatRow(label: 'Score', value: summary.score.toString()),
                _StatRow(
                  label: 'Time Alive',
                  value: _formatDuration(summary.timeAlive),
                ),
                _StatRow(
                  label: 'Enemies Defeated',
                  value: summary.enemiesDefeated.toString(),
                ),
                _StatRow(
                  label: 'XP Gained',
                  value: summary.xpGained.toString(),
                ),
                _StatRow(
                  label: 'Damage Taken',
                  value: summary.damageTaken.toStringAsFixed(0),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReturn,
                        child: const Text('Return Home'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: onRestart,
                        child: const Text('Restart Run'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final clamped = seconds.clamp(0, 24 * 60 * 60).toInt();
    final minutes = clamped ~/ 60;
    final secs = clamped % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, letterSpacing: 0.4),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
