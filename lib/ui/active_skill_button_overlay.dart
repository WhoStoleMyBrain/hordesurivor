import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/active_skill_defs.dart';
import '../data/ids.dart';
import 'hud_state.dart';

class ActiveSkillButtonOverlay extends StatelessWidget {
  const ActiveSkillButtonOverlay({
    super.key,
    required this.hudState,
    required this.activeSkillIcons,
    required this.onPressed,
  });

  static const String overlayKey = 'active_skill_button';

  final PlayerHudState hudState;
  final Map<ActiveSkillId, ui.Image?> activeSkillIcons;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 18, bottom: 128),
          child: AnimatedBuilder(
            animation: hudState,
            builder: (context, _) {
              final activeSkillId = hudState.activeSkillId;
              if (activeSkillId == null) {
                return const SizedBox.shrink();
              }
              final def = activeSkillDefsById[activeSkillId];
              if (def == null) {
                return const SizedBox.shrink();
              }
              final cooldownRemaining = hudState.activeSkillCooldownRemaining;
              final cooldownDuration = hudState.activeSkillCooldownDuration;
              final manaCost = hudState.activeSkillManaCost;
              final hasMana = hudState.mana >= manaCost;
              final ready = cooldownRemaining <= 0 && hasMana;
              final ratio = cooldownDuration > 0
                  ? (cooldownRemaining / cooldownDuration).clamp(0.0, 1.0)
                  : 0.0;
              return _ActiveSkillButton(
                icon: activeSkillIcons[activeSkillId],
                name: def.name,
                cooldownRemaining: cooldownRemaining,
                cooldownRatio: ratio,
                hasMana: hasMana,
                ready: ready,
                onPressed: ready ? onPressed : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActiveSkillButton extends StatelessWidget {
  const _ActiveSkillButton({
    required this.icon,
    required this.name,
    required this.cooldownRemaining,
    required this.cooldownRatio,
    required this.hasMana,
    required this.ready,
    required this.onPressed,
  });

  final ui.Image? icon;
  final String name;
  final double cooldownRemaining;
  final double cooldownRatio;
  final bool hasMana;
  final bool ready;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final borderColor = ready
        ? Colors.lightGreenAccent
        : hasMana
        ? Colors.orangeAccent
        : Colors.redAccent;
    final label = cooldownRemaining > 0
        ? '${cooldownRemaining.toStringAsFixed(1)}s'
        : hasMana
        ? 'READY'
        : 'NO MANA';
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: ready ? 1 : 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF151A23),
                border: Border.all(color: borderColor, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: RawImage(image: icon, fit: BoxFit.contain),
                    )
                  else
                    Icon(Icons.auto_fix_high, color: borderColor, size: 28),
                  Positioned.fill(
                    child: CircularProgressIndicator(
                      value: 1 - cooldownRatio,
                      strokeWidth: 4,
                      backgroundColor: Colors.black38,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        borderColor.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.white70),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: ready ? Colors.lightGreenAccent : Colors.white60,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
