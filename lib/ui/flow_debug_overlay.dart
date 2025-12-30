import 'package:flutter/material.dart';

import '../game/game_flow_state.dart';

class FlowDebugOverlay extends StatelessWidget {
  const FlowDebugOverlay({
    super.key,
    required this.flowState,
    required this.onSelectState,
    required this.onClose,
  });

  static const String overlayKey = 'flow_debug_overlay';

  final GameFlowState flowState;
  final ValueChanged<GameFlowState> onSelectState;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.bodyMedium?.copyWith(
      color: Colors.white70,
      fontWeight: FontWeight.w600,
    );
    return Align(
      alignment: Alignment.topLeft,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flow Debug — ${_labelFor(flowState)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: GameFlowState.values.map((state) {
                  final isActive = state == flowState;
                  return OutlinedButton(
                    onPressed: () => onSelectState(state),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isActive ? Colors.white : Colors.white70,
                      backgroundColor: isActive
                          ? Colors.white12
                          : Colors.transparent,
                    ),
                    child: Text(_labelFor(state), style: textStyle),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onClose,
                  child: const Text('Close'),
                ),
              ),
              Text(
                'Toggle: F1',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _labelFor(GameFlowState state) {
    switch (state) {
      case GameFlowState.start:
        return 'Start';
      case GameFlowState.homeBase:
        return 'Home Base';
      case GameFlowState.areaSelect:
        return 'Area Select';
      case GameFlowState.stage:
        return 'Stage';
      case GameFlowState.death:
        return 'Death';
    }
  }
}
