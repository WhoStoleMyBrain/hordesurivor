import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/item_defs.dart';
import 'scripture_card.dart';
import 'stat_text.dart';
import 'ui_scale.dart';

class ItemHoverTooltip extends StatefulWidget {
  const ItemHoverTooltip({
    super.key,
    required this.itemId,
    required this.child,
    this.cardBackground,
  });

  final ItemId itemId;
  final Widget child;
  final ui.Image? cardBackground;

  @override
  State<ItemHoverTooltip> createState() => _ItemHoverTooltipState();
}

class _ItemHoverTooltipState extends State<ItemHoverTooltip> {
  final LayerLink _link = LayerLink();
  OverlayEntry? _entry;

  @override
  void dispose() {
    _removeEntry();
    super.dispose();
  }

  void _showEntry() {
    if (_entry != null) {
      return;
    }
    _entry = OverlayEntry(
      builder: (context) {
        return Positioned.fill(
          child: IgnorePointer(
            child: CompositedTransformFollower(
              link: _link,
              offset: const Offset(0, -8),
              showWhenUnlinked: false,
              child: Material(
                color: Colors.transparent,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: _ItemTooltipCard(
                    itemId: widget.itemId,
                    cardBackground: widget.cardBackground,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _removeEntry() {
    _entry?.remove();
    _entry = null;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _showEntry(),
      onExit: (_) => _removeEntry(),
      child: CompositedTransformTarget(link: _link, child: widget.child),
    );
  }
}

class _ItemTooltipCard extends StatelessWidget {
  const _ItemTooltipCard({required this.itemId, this.cardBackground});

  final ItemId itemId;
  final ui.Image? cardBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = itemDefsById[itemId];
    final modifierLines = item == null
        ? const <String>[]
        : [
            for (final modifier in item.modifiers)
              StatText.formatModifier(modifier),
          ];
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        width: 240,
        child: ScriptureCard(
          backgroundImage: cardBackground,
          padding: const EdgeInsets.all(12),
          child: DefaultTextStyle(
            style:
                theme.textTheme.bodySmall?.copyWith(color: Colors.white70) ??
                const TextStyle(color: Colors.white70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item?.name ?? itemId.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFE9D7A8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (item != null) ...[
                  const SizedBox(height: 6),
                  Text(item.description),
                ],
                if (modifierLines.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  for (final line in modifierLines)
                    Text(
                      line,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white60,
                        fontSize: UiScale.fontSize(11),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
