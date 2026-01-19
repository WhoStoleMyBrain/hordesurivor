import 'ids.dart';
import 'stat_defs.dart';
import 'tags.dart';

class ItemDef {
  const ItemDef({
    required this.id,
    required this.name,
    required this.description,
    required this.modifiers,
    required this.rarity,
    this.metaUnlockId,
    this.tags = const TagSet(),
    this.weight = 1,
    this.maxStacks,
  });

  final ItemId id;
  final String name;
  final String description;
  final List<StatModifier> modifiers;
  final ItemRarity rarity;
  final MetaUnlockId? metaUnlockId;
  final TagSet tags;
  final int weight;
  final int? maxStacks;
}

const List<ItemDef> itemDefs = [
  ItemDef(
    id: ItemId.glassCatalyst,
    name: 'Glass Catalyst',
    description: 'High output at the cost of survivability.',
    modifiers: [
      StatModifier(stat: StatId.damage, amount: 0.2),
      StatModifier(
        stat: StatId.flatDamage,
        amount: 1.0,
        kind: ModifierKind.flat,
      ),
      StatModifier(stat: StatId.maxHp, amount: -0.2),
    ],
    rarity: ItemRarity.uncommon,
    maxStacks: 4,
  ),
  ItemDef(
    id: ItemId.heavyPlate,
    name: 'Heavy Plate',
    description: 'Armored weight slows movement.',
    modifiers: [
      StatModifier(stat: StatId.maxHp, amount: 0.18),
      StatModifier(stat: StatId.moveSpeedPercent, amount: -0.1),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.reinforcedPlating,
    name: 'Reinforced Plating',
    description: 'Thicker armor trades off some mobility.',
    modifiers: [
      StatModifier(stat: StatId.armor, amount: 1.5, kind: ModifierKind.flat),
      StatModifier(stat: StatId.moveSpeedPercent, amount: -0.08),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.featherBoots,
    name: 'Feather Boots',
    description: 'Swift steps with reduced protection.',
    modifiers: [
      StatModifier(stat: StatId.moveSpeedPercent, amount: 0.15),
      StatModifier(stat: StatId.defense, amount: -0.1),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.overclockedTrigger,
    name: 'Overclocked Trigger',
    description: 'Rapid fire output with weaker hits.',
    modifiers: [
      StatModifier(stat: StatId.attackSpeed, amount: 0.18),
      StatModifier(stat: StatId.damage, amount: -0.1),
    ],
    rarity: ItemRarity.common,
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
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.wideLens,
    name: 'Wide Lens',
    description: 'Broader impact area and view with slower cadence.',
    modifiers: [
      StatModifier(stat: StatId.aoeSize, amount: 0.25),
      StatModifier(stat: StatId.fieldOfView, amount: 0.1),
      StatModifier(stat: StatId.attackSpeed, amount: -0.15),
    ],
    tags: TagSet(effects: {EffectTag.aoe}),
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.sharpeningStone,
    name: 'Sharpening Stone',
    description: 'Melee edge honed at ranged expense.',
    modifiers: [
      StatModifier(stat: StatId.meleeDamage, amount: 0.18),
      StatModifier(stat: StatId.projectileDamage, amount: -0.12),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.focusingNozzle,
    name: 'Focusing Nozzle',
    description: 'Amplify beams while shrinking blast area.',
    modifiers: [
      StatModifier(stat: StatId.beamDamage, amount: 0.18),
      StatModifier(stat: StatId.aoeSize, amount: -0.1),
    ],
    tags: TagSet(deliveries: {DeliveryTag.beam}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.volatileMixture,
    name: 'Volatile Mixture',
    description: 'Explosions hit harder but hurt you too.',
    modifiers: [
      StatModifier(stat: StatId.explosionDamage, amount: 0.4),
      StatModifier(stat: StatId.fireDamage, amount: 0.2),
      StatModifier(stat: StatId.elementalDamage, amount: 0.1),
      StatModifier(
        stat: StatId.flatElementalDamage,
        amount: 1.2,
        kind: ModifierKind.flat,
      ),
      StatModifier(stat: StatId.selfExplosionDamageTaken, amount: 0.3),
    ],
    tags: TagSet(elements: {ElementTag.fire}),
    rarity: ItemRarity.epic,
    maxStacks: 1,
  ),
  ItemDef(
    id: ItemId.insulatedFlask,
    name: 'Insulated Flask',
    description: 'Water techniques improve as fire wanes.',
    modifiers: [
      StatModifier(stat: StatId.waterDamage, amount: 0.18),
      StatModifier(stat: StatId.fireDamage, amount: -0.12),
    ],
    tags: TagSet(elements: {ElementTag.water}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.toxicFilters,
    name: 'Toxic Filters',
    description: 'Filter poison but inhibit recovery.',
    modifiers: [
      StatModifier(stat: StatId.poisonResistance, amount: 0.22),
      StatModifier(stat: StatId.healingReceived, amount: -0.12),
    ],
    tags: TagSet(elements: {ElementTag.poison}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.briarCharm,
    name: 'Briar Charm',
    description: 'Roots last longer but slow you down.',
    modifiers: [
      StatModifier(stat: StatId.rootDuration, amount: 0.25),
      StatModifier(stat: StatId.rootStrength, amount: 0.2),
      StatModifier(stat: StatId.moveSpeedPercent, amount: -0.1),
    ],
    tags: TagSet(elements: {ElementTag.earth, ElementTag.wood}),
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.ironGrip,
    name: 'Iron Grip',
    description: 'Stronger knockback with slower attacks.',
    modifiers: [
      StatModifier(stat: StatId.knockbackStrength, amount: 0.22),
      StatModifier(stat: StatId.attackSpeed, amount: -0.1),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.vampiricSeal,
    name: 'Vampiric Seal',
    description: 'Leech life but cap your vitality.',
    modifiers: [
      StatModifier(stat: StatId.lifeSteal, amount: 0.15),
      StatModifier(stat: StatId.maxHp, amount: -0.15),
    ],
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.luckyCoin,
    name: 'Lucky Coin',
    description: 'Better drops for reduced damage.',
    modifiers: [
      StatModifier(stat: StatId.drops, amount: 0.15),
      StatModifier(stat: StatId.damage, amount: -0.1),
    ],
    rarity: ItemRarity.common,
    maxStacks: 4,
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
    rarity: ItemRarity.uncommon,
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
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.evasiveTalisman,
    name: 'Evasive Talisman',
    description: 'Sharper dodges leave you more fragile.',
    modifiers: [
      StatModifier(stat: StatId.dodgeChance, amount: 0.08),
      StatModifier(stat: StatId.maxHp, amount: -0.08),
    ],
    tags: TagSet(effects: {EffectTag.mobility}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.ritualCandle,
    name: 'Ritual Candle',
    description: 'Fire damage over time rises, water wanes.',
    modifiers: [
      StatModifier(stat: StatId.dotDamage, amount: 0.2),
      StatModifier(stat: StatId.fireDamage, amount: 0.2),
      StatModifier(stat: StatId.elementalDamage, amount: 0.05),
      StatModifier(stat: StatId.waterDamage, amount: -0.15),
    ],
    tags: TagSet(elements: {ElementTag.fire}),
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.slickSoles,
    name: 'Slick Soles',
    description: 'Mobility effects intensify but aim falters.',
    modifiers: [
      StatModifier(stat: StatId.moveSpeedPercent, amount: 0.12),
      StatModifier(stat: StatId.accuracy, amount: -0.12),
    ],
    tags: TagSet(effects: {EffectTag.mobility}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.backpackOfGlass,
    name: 'Backpack of Glass',
    description: 'Extra pickup reach with fragile capacity.',
    modifiers: [
      StatModifier(stat: StatId.pickupRadiusPercent, amount: 0.18),
      StatModifier(stat: StatId.maxHp, amount: -0.12),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.thermalCoil,
    name: 'Thermal Coil',
    description: 'Ignitions burn longer, but shots hit softer.',
    modifiers: [
      StatModifier(stat: StatId.dotDuration, amount: 0.3),
      StatModifier(stat: StatId.fireDamage, amount: 0.2),
      StatModifier(stat: StatId.elementalDamage, amount: 0.08),
      StatModifier(stat: StatId.projectileDamage, amount: -0.18),
    ],
    metaUnlockId: MetaUnlockId.thermalCoilBlueprint,
    tags: TagSet(elements: {ElementTag.fire}, effects: {EffectTag.dot}),
    rarity: ItemRarity.rare,
  ),
  ItemDef(
    id: ItemId.hydraulicStabilizer,
    name: 'Hydraulic Stabilizer',
    description: 'Steadier beams widen impact, slowing your stride.',
    modifiers: [
      StatModifier(stat: StatId.beamDamage, amount: 0.3),
      StatModifier(stat: StatId.aoeSize, amount: 0.2),
      StatModifier(stat: StatId.moveSpeedPercent, amount: -0.12),
    ],
    metaUnlockId: MetaUnlockId.hydraulicStabilizerPermit,
    tags: TagSet(deliveries: {DeliveryTag.beam}),
    rarity: ItemRarity.rare,
  ),
  ItemDef(
    id: ItemId.sporeSatchel,
    name: 'Spore Satchel',
    description: 'Poison blooms stronger, healing feels weaker.',
    modifiers: [
      StatModifier(stat: StatId.dotDamage, amount: 0.25),
      StatModifier(stat: StatId.poisonResistance, amount: 0.25),
      StatModifier(stat: StatId.healingReceived, amount: -0.25),
    ],
    metaUnlockId: MetaUnlockId.sporeSatchelKit,
    tags: TagSet(elements: {ElementTag.poison}, effects: {EffectTag.dot}),
    rarity: ItemRarity.rare,
  ),
  ItemDef(
    id: ItemId.gravelBoots,
    name: 'Gravel Boots',
    description: 'Heavier steps shove foes back, but slow your tempo.',
    modifiers: [
      StatModifier(stat: StatId.knockbackStrength, amount: 0.25),
      StatModifier(stat: StatId.attackSpeed, amount: -0.15),
    ],
    metaUnlockId: MetaUnlockId.gravelBootsPattern,
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.moltenBuckle,
    name: 'Molten Buckle',
    description: 'Volatile blasts surge, self-burn included.',
    modifiers: [
      StatModifier(stat: StatId.explosionDamage, amount: 0.35),
      StatModifier(stat: StatId.fireDamage, amount: 0.25),
      StatModifier(stat: StatId.elementalDamage, amount: 0.1),
      StatModifier(stat: StatId.selfExplosionDamageTaken, amount: 0.35),
    ],
    metaUnlockId: MetaUnlockId.moltenBuckleForge,
    tags: TagSet(elements: {ElementTag.fire}),
    rarity: ItemRarity.epic,
    maxStacks: 1,
  ),
  ItemDef(
    id: ItemId.serratedEdge,
    name: 'Serrated Edge',
    description: 'Melee cuts linger, ranged force fades.',
    modifiers: [
      StatModifier(stat: StatId.meleeDamage, amount: 0.25),
      StatModifier(stat: StatId.dotDamage, amount: 0.2),
      StatModifier(stat: StatId.projectileDamage, amount: -0.25),
    ],
    metaUnlockId: MetaUnlockId.serratedEdgeRecipe,
    tags: TagSet(effects: {EffectTag.dot}),
    rarity: ItemRarity.rare,
  ),
  ItemDef(
    id: ItemId.mercyCharm,
    name: 'Mercy Charm',
    description:
        'Healing strengthens with steady recovery, raw damage softens.',
    modifiers: [
      StatModifier(stat: StatId.healingReceived, amount: 0.3),
      StatModifier(stat: StatId.damage, amount: -0.2),
      StatModifier(stat: StatId.hpRegen, amount: 0.8, kind: ModifierKind.flat),
    ],
    metaUnlockId: MetaUnlockId.mercyCharmVow,
    tags: TagSet(effects: {EffectTag.support}),
    rarity: ItemRarity.rare,
  ),
];

final Map<ItemId, ItemDef> itemDefsById = Map.unmodifiable({
  for (final def in itemDefs) def.id: def,
});
