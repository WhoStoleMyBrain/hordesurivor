import 'package:flutter/material.dart';

import '../data/ids.dart';
import '../data/tags.dart';
import 'ui_scale.dart';

class TagBadgeData {
  TagBadgeData({required this.label, required this.icon, required this.color});

  final String label;
  final IconData icon;
  final Color color;
}

class TagBadge extends StatelessWidget {
  const TagBadge({super.key, required this.data});

  final TagBadgeData data;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: data.color.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(data.icon, size: 12, color: data.color),
            const SizedBox(width: 4),
            Text(
              data.label,
              style: TextStyle(
                fontSize: UiScale.fontSize(11),
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<TagBadgeData> tagBadgesForTags(TagSet tags) {
  final badges = <TagBadgeData>[
    for (final tag in tags.elements) _elementBadge(tag),
    for (final tag in tags.effects) _effectBadge(tag),
    for (final tag in tags.deliveries) _deliveryBadge(tag),
  ];
  return badges;
}

List<TagBadgeData> statusBadgesForEffects(
  Iterable<StatusEffectId> statusEffects,
) {
  return [for (final status in statusEffects) _statusBadge(status)];
}

TagBadgeData _elementBadge(ElementTag tag) {
  switch (tag) {
    case ElementTag.fire:
      return TagBadgeData(
        label: 'Fire',
        icon: Icons.local_fire_department,
        color: const Color(0xFFF56D5B),
      );
    case ElementTag.water:
      return TagBadgeData(
        label: 'Water',
        icon: Icons.water_drop,
        color: const Color(0xFF4DB8FF),
      );
    case ElementTag.earth:
      return TagBadgeData(
        label: 'Earth',
        icon: Icons.terrain,
        color: const Color(0xFFB5895B),
      );
    case ElementTag.wind:
      return TagBadgeData(
        label: 'Wind',
        icon: Icons.air,
        color: const Color(0xFF9EE6E6),
      );
    case ElementTag.poison:
      return TagBadgeData(
        label: 'Poison',
        icon: Icons.science,
        color: const Color(0xFF9BE564),
      );
    case ElementTag.steel:
      return TagBadgeData(
        label: 'Steel',
        icon: Icons.construction,
        color: const Color(0xFFB0BEC5),
      );
    case ElementTag.wood:
      return TagBadgeData(
        label: 'Wood',
        icon: Icons.park,
        color: const Color(0xFF8BC34A),
      );
  }
}

TagBadgeData _effectBadge(EffectTag tag) {
  switch (tag) {
    case EffectTag.aoe:
      return TagBadgeData(
        label: 'AOE',
        icon: Icons.blur_circular,
        color: const Color(0xFFB388FF),
      );
    case EffectTag.dot:
      return TagBadgeData(
        label: 'DOT',
        icon: Icons.blur_on,
        color: const Color(0xFFFFC857),
      );
    case EffectTag.support:
      return TagBadgeData(
        label: 'Support',
        icon: Icons.healing,
        color: const Color(0xFF7BDFF2),
      );
    case EffectTag.debuff:
      return TagBadgeData(
        label: 'Debuff',
        icon: Icons.report_problem,
        color: const Color(0xFFF28482),
      );
    case EffectTag.mobility:
      return TagBadgeData(
        label: 'Mobility',
        icon: Icons.directions_run,
        color: const Color(0xFF8BD3FF),
      );
  }
}

TagBadgeData _deliveryBadge(DeliveryTag tag) {
  switch (tag) {
    case DeliveryTag.projectile:
      return TagBadgeData(
        label: 'Projectile',
        icon: Icons.arrow_forward,
        color: const Color(0xFFFF9F1C),
      );
    case DeliveryTag.beam:
      return TagBadgeData(
        label: 'Beam',
        icon: Icons.bolt,
        color: const Color(0xFF5BC0EB),
      );
    case DeliveryTag.melee:
      return TagBadgeData(
        label: 'Melee',
        icon: Icons.gavel,
        color: const Color(0xFFB0BEC5),
      );
    case DeliveryTag.aura:
      return TagBadgeData(
        label: 'Aura',
        icon: Icons.radio_button_checked,
        color: const Color(0xFFB8F2E6),
      );
    case DeliveryTag.ground:
      return TagBadgeData(
        label: 'Ground',
        icon: Icons.layers,
        color: const Color(0xFFE6BEAE),
      );
  }
}

TagBadgeData _statusBadge(StatusEffectId status) {
  switch (status) {
    case StatusEffectId.slow:
      return TagBadgeData(
        label: 'Slow',
        icon: Icons.ac_unit,
        color: const Color(0xFF7FD1FF),
      );
    case StatusEffectId.root:
      return TagBadgeData(
        label: 'Root',
        icon: Icons.nature_people,
        color: const Color(0xFF7FB77E),
      );
    case StatusEffectId.ignite:
      return TagBadgeData(
        label: 'Ignite',
        icon: Icons.local_fire_department,
        color: const Color(0xFFF56D5B),
      );
    case StatusEffectId.oilSoaked:
      return TagBadgeData(
        label: 'Oil',
        icon: Icons.opacity,
        color: const Color(0xFFB08968),
      );
    case StatusEffectId.vulnerable:
      return TagBadgeData(
        label: 'Vulnerable',
        icon: Icons.flash_on,
        color: const Color(0xFFF4B860),
      );
  }
}
