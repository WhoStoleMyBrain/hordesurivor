import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/meta_unlock_defs.dart';
import '../game/meta_currency_wallet.dart';
import '../game/meta_unlocks.dart';
import 'meta_shard_badge.dart';

class MetaUnlockScreen extends StatelessWidget {
  const MetaUnlockScreen({
    super.key,
    required this.wallet,
    required this.unlocks,
    required this.onClose,
  });

  static const String overlayKey = 'meta_unlock_screen';

  final MetaCurrencyWallet wallet;
  final MetaUnlocks unlocks;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.black.withValues(alpha: 0.75),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: AnimatedBuilder(
                animation: Listenable.merge([wallet, unlocks]),
                builder: (context, _) {
                  final isReady = wallet.isLoaded && unlocks.isLoaded;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Meta Unlocks',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Spend Meta Shards to unlock lateral options. '
                        'Hover nodes to see details and click to unlock.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      MetaShardBadge(wallet: wallet),
                      const SizedBox(height: 20),
                      Flexible(
                        child: MetaUnlockTree(
                          wallet: wallet,
                          unlocks: unlocks,
                          isReady: isReady,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onClose,
                          child: const Text('Back'),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MetaUnlockTree extends StatelessWidget {
  const MetaUnlockTree({
    super.key,
    required this.wallet,
    required this.unlocks,
    required this.isReady,
  });

  final MetaCurrencyWallet wallet;
  final MetaUnlocks unlocks;
  final bool isReady;

  @override
  Widget build(BuildContext context) {
    const nodeSize = 64.0;
    const spacing = 92.0;
    final positions = <MetaUnlockId, Offset>{
      for (final def in metaUnlockDefs)
        def.id: Offset(
          def.position.column * spacing,
          def.position.row * spacing,
        ),
    };
    final unlockedIds = unlocks.unlockedIds.toSet();
    final maxColumn = metaUnlockDefs
        .map((def) => def.position.column)
        .fold<int>(0, (value, element) => element > value ? element : value);
    final maxRow = metaUnlockDefs
        .map((def) => def.position.row)
        .fold<int>(0, (value, element) => element > value ? element : value);
    final size = Size(
      (maxColumn * spacing) + nodeSize,
      (maxRow * spacing) + nodeSize,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.black.withValues(alpha: 0.4),
        padding: const EdgeInsets.all(12),
        child: InteractiveViewer(
          constrained: false,
          minScale: 0.8,
          maxScale: 1.4,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: Stack(
              children: [
                CustomPaint(
                  size: size,
                  painter: MetaUnlockConnectionsPainter(
                    positions: positions,
                    unlockedIds: unlockedIds,
                  ),
                ),
                for (final def in metaUnlockDefs)
                  Positioned(
                    left: positions[def.id]!.dx,
                    top: positions[def.id]!.dy,
                    width: nodeSize,
                    child: MetaUnlockNode(
                      def: def,
                      unlocks: unlocks,
                      wallet: wallet,
                      isReady: isReady,
                      size: nodeSize,
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

class MetaUnlockNode extends StatelessWidget {
  const MetaUnlockNode({
    super.key,
    required this.def,
    required this.unlocks,
    required this.wallet,
    required this.isReady,
    required this.size,
  });

  final MetaUnlockDef def;
  final MetaUnlocks unlocks;
  final MetaCurrencyWallet wallet;
  final bool isReady;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = unlocks.isUnlocked(def.id);
    final unlockable = unlocks.canUnlock(def.id);
    final canPurchase =
        isReady && unlockable && !unlocked && wallet.balance >= def.cost;
    final borderColor = unlocked
        ? Colors.greenAccent
        : canPurchase
        ? Colors.amberAccent
        : unlockable
        ? Colors.white54
        : Colors.white24;
    final fillColor = unlocked
        ? Colors.greenAccent.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.6);

    final tooltipMessage = StringBuffer()
      ..writeln(def.name)
      ..writeln(def.description)
      ..write(unlocked ? 'Unlocked' : 'Cost: ${def.cost} shards');

    return Tooltip(
      message: tooltipMessage.toString(),
      textAlign: TextAlign.center,
      preferBelow: false,
      child: MouseRegion(
        cursor: canPurchase ? SystemMouseCursors.click : MouseCursor.defer,
        child: GestureDetector(
          onTap: canPurchase
              ? () {
                  unlocks.purchase(def.id, wallet: wallet);
                }
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: Center(
                  child: MetaUnlockSprite(
                    color: unlocked ? Colors.greenAccent : Colors.white70,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: size + 12,
                child: Text(
                  def.name,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MetaUnlockConnectionsPainter extends CustomPainter {
  MetaUnlockConnectionsPainter({
    required this.positions,
    required this.unlockedIds,
  });

  final Map<MetaUnlockId, Offset> positions;
  final Set<MetaUnlockId> unlockedIds;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    const nodeRadius = 32.0;

    for (final def in metaUnlockDefs) {
      final start = positions[def.id];
      if (start == null) {
        continue;
      }
      for (final prereq in def.prerequisites) {
        final end = positions[prereq];
        if (end == null) {
          continue;
        }
        final unlocked = unlockedIds.contains(def.id);
        final prereqUnlocked = unlockedIds.contains(prereq);
        paint.color = unlocked && prereqUnlocked
            ? Colors.greenAccent
            : prereqUnlocked
            ? Colors.white54
            : Colors.white24;
        canvas.drawLine(
          start + const Offset(nodeRadius, nodeRadius),
          end + const Offset(nodeRadius, nodeRadius),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MetaUnlockConnectionsPainter oldDelegate) {
    return oldDelegate.positions != positions ||
        !setEquals(oldDelegate.unlockedIds, unlockedIds);
  }
}

class MetaUnlockSprite extends StatelessWidget {
  const MetaUnlockSprite({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(32, 32),
      painter: MetaUnlockSpritePainter(color: color),
    );
  }
}

class MetaUnlockSpritePainter extends CustomPainter {
  MetaUnlockSpritePainter({required this.color});

  final Color color;

  static const List<List<int>> _pixels = [
    [0, 1, 1, 1, 1, 0],
    [1, 1, 1, 1, 1, 1],
    [1, 1, 0, 0, 1, 1],
    [1, 1, 0, 0, 1, 1],
    [1, 1, 1, 1, 1, 1],
    [0, 1, 1, 1, 1, 0],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final pixelSize = size.width / _pixels.length;
    for (var y = 0; y < _pixels.length; y++) {
      for (var x = 0; x < _pixels[y].length; x++) {
        if (_pixels[y][x] == 1) {
          canvas.drawRect(
            Rect.fromLTWH(x * pixelSize, y * pixelSize, pixelSize, pixelSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant MetaUnlockSpritePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
