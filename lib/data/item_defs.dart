import 'ids.dart';
import 'stat_defs.dart';
import 'tags.dart';

class ItemDef {
  const ItemDef({
    required this.id,
    required this.name,
    required this.description,
    required this.modifiers,
    this.tags = const TagSet(),
    this.weight = 1,
  });

  final ItemId id;
  final String name;
  final String description;
  final List<StatModifier> modifiers;
  final TagSet tags;
  final int weight;
}

const List<ItemDef> itemDefs = [
  ItemDef(
    id: ItemId.glassCatalyst,
    name: 'Glass Catalyst',
    description: 'High output at the cost of survivability.',
    modifiers: [
      StatModifier(stat: StatId.damage, amount: 0.2),
      StatModifier(stat: StatId.maxHp, amount: -0.2),
    ],
  ),
  ItemDef(
    id: ItemId.heavyPlate,
    name: 'Heavy Plate',
    description: 'Armored weight slows movement.',
    modifiers: [
      StatModifier(stat: StatId.maxHp, amount: 0.25),
      StatModifier(stat: StatId.moveSpeed, amount: -0.15),
    ],
  ),
  ItemDef(
    id: ItemId.featherBoots,
    name: 'Feather Boots',
    description: 'Swift steps with reduced protection.',
    modifiers: [
      StatModifier(stat: StatId.moveSpeed, amount: 0.2),
      StatModifier(stat: StatId.defense, amount: -0.15),
    ],
  ),
  ItemDef(
    id: ItemId.overclockedTrigger,
    name: 'Overclocked Trigger',
    description: 'Rapid fire output with weaker hits.',
    modifiers: [
      StatModifier(stat: StatId.attackSpeed, amount: 0.25),
      StatModifier(stat: StatId.damage, amount: -0.15),
    ],
  ),
  ItemDef(
    id: ItemId.slowCooker,
    name: 'Slow Cooker',
    description: 'Damage over time rises, direct hits suffer.',
    modifiers: [
      StatModifier(stat: StatId.dotDamage, amount: 0.25),
      StatModifier(stat: StatId.dotDuration, amount: 0.2),
      StatModifier(stat: StatId.directHitDamage, amount: -0.2),
    ],
    tags: TagSet(effects: {EffectTag.dot}),
  ),
  ItemDef(
    id: ItemId.wideLens,
    name: 'Wide Lens',
    description: 'Broader impact area with slower cadence.',
    modifiers: [
      StatModifier(stat: StatId.aoeSize, amount: 0.25),
      StatModifier(stat: StatId.attackSpeed, amount: -0.15),
    ],
    tags: TagSet(effects: {EffectTag.aoe}),
  ),
  ItemDef(
    id: ItemId.sharpeningStone,
    name: 'Sharpening Stone',
    description: 'Melee edge honed at ranged expense.',
    modifiers: [
      StatModifier(stat: StatId.meleeDamage, amount: 0.25),
      StatModifier(stat: StatId.projectileDamage, amount: -0.2),
    ],
  ),
  ItemDef(
    id: ItemId.focusingNozzle,
    name: 'Focusing Nozzle',
    description: 'Amplify beams while shrinking blast area.',
    modifiers: [
      StatModifier(stat: StatId.beamDamage, amount: 0.25),
      StatModifier(stat: StatId.aoeSize, amount: -0.15),
    ],
    tags: TagSet(deliveries: {DeliveryTag.beam}),
  ),
  ItemDef(
    id: ItemId.volatileMixture,
    name: 'Volatile Mixture',
    description: 'Explosions hit harder but hurt you too.',
    modifiers: [
      StatModifier(stat: StatId.explosionDamage, amount: 0.3),
      StatModifier(stat: StatId.fireDamage, amount: 0.15),
      StatModifier(stat: StatId.selfExplosionDamageTaken, amount: 0.2),
    ],
    tags: TagSet(elements: {ElementTag.fire}),
  ),
  ItemDef(
    id: ItemId.insulatedFlask,
    name: 'Insulated Flask',
    description: 'Water techniques improve as fire wanes.',
    modifiers: [
      StatModifier(stat: StatId.waterDamage, amount: 0.25),
      StatModifier(stat: StatId.fireDamage, amount: -0.2),
    ],
    tags: TagSet(elements: {ElementTag.water}),
  ),
  ItemDef(
    id: ItemId.toxicFilters,
    name: 'Toxic Filters',
    description: 'Filter poison but inhibit recovery.',
    modifiers: [
      StatModifier(stat: StatId.poisonResistance, amount: 0.3),
      StatModifier(stat: StatId.healingReceived, amount: -0.2),
    ],
    tags: TagSet(elements: {ElementTag.poison}),
  ),
  ItemDef(
    id: ItemId.briarCharm,
    name: 'Briar Charm',
    description: 'Roots last longer but slow you down.',
    modifiers: [
      StatModifier(stat: StatId.rootDuration, amount: 0.25),
      StatModifier(stat: StatId.rootStrength, amount: 0.2),
      StatModifier(stat: StatId.moveSpeed, amount: -0.1),
    ],
    tags: TagSet(elements: {ElementTag.earth, ElementTag.wood}),
  ),
  ItemDef(
    id: ItemId.ironGrip,
    name: 'Iron Grip',
    description: 'Stronger knockback with slower attacks.',
    modifiers: [
      StatModifier(stat: StatId.knockbackStrength, amount: 0.3),
      StatModifier(stat: StatId.attackSpeed, amount: -0.15),
    ],
  ),
  ItemDef(
    id: ItemId.vampiricSeal,
    name: 'Vampiric Seal',
    description: 'Leech life but cap your vitality.',
    modifiers: [
      StatModifier(stat: StatId.lifeSteal, amount: 0.15),
      StatModifier(stat: StatId.maxHp, amount: -0.15),
    ],
  ),
  ItemDef(
    id: ItemId.luckyCoin,
    name: 'Lucky Coin',
    description: 'Better drops for reduced damage.',
    modifiers: [
      StatModifier(stat: StatId.drops, amount: 0.2),
      StatModifier(stat: StatId.damage, amount: -0.15),
    ],
  ),
  ItemDef(
    id: ItemId.gamblersDie,
    name: 'Gambler\'s Die',
    description: 'More rerolls but fewer choices at once.',
    modifiers: [
      StatModifier(stat: StatId.rerolls, amount: 1, kind: ModifierKind.flat),
      StatModifier(
        stat: StatId.choiceCount,
        amount: -1,
        kind: ModifierKind.flat,
      ),
    ],
  ),
  ItemDef(
    id: ItemId.reactiveShield,
    name: 'Reactive Shield',
    description: 'Periodic shield at the cost of recovery.',
    modifiers: [
      StatModifier(stat: StatId.defense, amount: 0.2),
      StatModifier(stat: StatId.cooldownRecovery, amount: -0.15),
    ],
    tags: TagSet(effects: {EffectTag.support}),
  ),
  ItemDef(
    id: ItemId.ritualCandle,
    name: 'Ritual Candle',
    description: 'Fire damage over time rises, water wanes.',
    modifiers: [
      StatModifier(stat: StatId.dotDamage, amount: 0.2),
      StatModifier(stat: StatId.fireDamage, amount: 0.2),
      StatModifier(stat: StatId.waterDamage, amount: -0.15),
    ],
    tags: TagSet(elements: {ElementTag.fire}),
  ),
  ItemDef(
    id: ItemId.slickSoles,
    name: 'Slick Soles',
    description: 'Mobility effects intensify but aim falters.',
    modifiers: [
      StatModifier(stat: StatId.moveSpeed, amount: 0.15),
      StatModifier(stat: StatId.accuracy, amount: -0.2),
    ],
    tags: TagSet(effects: {EffectTag.mobility}),
  ),
  ItemDef(
    id: ItemId.backpackOfGlass,
    name: 'Backpack of Glass',
    description: 'Extra pickup reach with fragile capacity.',
    modifiers: [
      StatModifier(stat: StatId.pickupRadius, amount: 0.25),
      StatModifier(stat: StatId.maxHp, amount: -0.2),
    ],
  ),
];

final Map<ItemId, ItemDef> itemDefsById = Map.unmodifiable({
  for (final def in itemDefs) def.id: def,
});
