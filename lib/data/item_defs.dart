import 'ids.dart';
import 'stat_defs.dart';
import 'tags.dart';

class ItemDef {
  const ItemDef({
    required this.id,
    required this.name,
    required this.iconId,
    required this.description,
    required this.flavorText,
    required this.modifiers,
    required this.rarity,
    this.metaUnlockId,
    this.tags = const TagSet(),
    this.weight = 1,
    this.maxStacks,
  });

  final ItemId id;
  final String name;
  final String iconId;
  final String description;
  final String flavorText;
  final List<StatModifier> modifiers;
  final ItemRarity rarity;
  final MetaUnlockId? metaUnlockId;
  final TagSet tags;
  final int weight;
  final int? maxStacks;
}

const List<ItemDef> commonItems = [
  ItemDef(
    id: ItemId.heavyPlate,
    name: 'Rite of Iron Weight',
    iconId: 'item_heavy_plate',
    description: 'Blessing: +Max HP / Burden: -Dodge Chance',
    flavorText: 'You feel protected and slightly overqualified for walking.',
    modifiers: [
      StatModifier(stat: StatId.maxHp, amount: 0.05),
      StatModifier(stat: StatId.dodgeChance, amount: -0.03),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.reinforcedPlating,
    name: 'Relic: Riveted Plate',
    iconId: 'item_reinforced_plating',
    description: 'Blessing: +Defense / Burden: -Dodge Chance',
    flavorText: 'The extra layer makes doors take it personally.',
    modifiers: [
      StatModifier(stat: StatId.defense, amount: 0.05),
      StatModifier(stat: StatId.dodgeChance, amount: -0.03),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.featherBoots,
    name: 'Vow of Swift Soles',
    iconId: 'item_feather_boots',
    description: 'Blessing: +Dodge Chance / Burden: -Defense',
    flavorText: 'Your ankles have filed a gentle complaint.',
    modifiers: [
      StatModifier(stat: StatId.dodgeChance, amount: 0.05),
      StatModifier(stat: StatId.defense, amount: -0.03),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.overclockedTrigger,
    name: 'Rite of Hasty Hands',
    iconId: 'item_overclocked_trigger',
    description: 'Blessing: +Attack Speed / Burden: -Damage',
    flavorText: 'Your form is impeccable; your impact is not.',
    modifiers: [
      StatModifier(stat: StatId.attackSpeed, amount: 0.10),
      StatModifier(stat: StatId.damagePercent, amount: -0.03),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.sharpeningStone,
    name: 'Relic: Honing Stone',
    iconId: 'item_sharpening_stone',
    description: 'Blessing: +Melee Damage / Burden: -Projectile Damage',
    flavorText: 'Sharp enough to shave, still bad at throwing.',
    modifiers: [
      StatModifier(stat: StatId.meleeDamagePercent, amount: 0.5),
      StatModifier(stat: StatId.projectileDamagePercent, amount: -0.02),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.focusingNozzle,
    name: 'Rite of Narrow Beams',
    iconId: 'item_focusing_nozzle',
    description: 'Blessing: +Beam Damage / Burden: -Area Size',
    flavorText: 'All the power, none of the breathing room.',
    modifiers: [
      StatModifier(stat: StatId.beamDamagePercent, amount: 0.12),
      StatModifier(stat: StatId.aoeSize, amount: -0.06),
    ],
    tags: TagSet(deliveries: {DeliveryTag.beam}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.insulatedFlask,
    name: 'Relic: Chilled Flask',
    iconId: 'item_insulated_flask',
    description: 'Blessing: +Water Damage / Burden: -Fire Damage',
    flavorText: 'Fire politely declines.',
    modifiers: [
      StatModifier(stat: StatId.waterDamagePercent, amount: 0.12),
      StatModifier(stat: StatId.fireDamagePercent, amount: -0.08),
    ],
    tags: TagSet(elements: {ElementTag.water}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.toxicFilters,
    name: 'Relic: Purifying Filter',
    iconId: 'item_toxic_filters',
    description: 'Blessing: +Defense / Burden: -Healing Received',
    flavorText: 'It keeps out toxins and most good intentions.',
    modifiers: [
      StatModifier(stat: StatId.defense, amount: 0.08),
      StatModifier(stat: StatId.healingReceivedPercent, amount: -0.08),
    ],
    tags: TagSet(elements: {ElementTag.poison}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.ironGrip,
    name: 'Rite of Iron Grip',
    iconId: 'item_iron_grip',
    description: 'Blessing: +Banishment Force / Burden: -Attack Speed',
    flavorText: 'Great for shoving, poor for keeping tempo.',
    modifiers: [
      StatModifier(stat: StatId.banishmentForce, amount: 0.14),
      StatModifier(stat: StatId.attackSpeed, amount: -0.06),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.luckyCoin,
    name: 'Vow of Fortune',
    iconId: 'item_lucky_coin',
    description: 'Blessing: +Drops / Burden: -Damage',
    flavorText: 'The coin likes you more than your targets do.',
    modifiers: [
      StatModifier(stat: StatId.dropsPercent, amount: 0.1),
      StatModifier(stat: StatId.damagePercent, amount: -0.06),
    ],
    rarity: ItemRarity.common,
    maxStacks: 4,
  ),
  ItemDef(
    id: ItemId.evasiveTalisman,
    name: 'Relic: Skittish Talisman',
    iconId: 'item_evasive_talisman',
    description: 'Blessing: +Dodge Chance / Burden: -Max HP',
    flavorText: 'The body dodges; the paperwork says fragile.',
    modifiers: [
      StatModifier(stat: StatId.dodgeChance, amount: 0.06),
      StatModifier(stat: StatId.maxHp, amount: -0.05),
    ],
    tags: TagSet(effects: {EffectTag.mobility}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.slickSoles,
    name: 'Rite of Slick Soles',
    iconId: 'item_slick_soles',
    description: 'Blessing: +Dodge Chance / Burden: -Accuracy',
    flavorText: 'You glide gracefully past the thing you meant to hit.',
    modifiers: [
      StatModifier(stat: StatId.dodgeChance, amount: 0.08),
      StatModifier(stat: StatId.accuracy, amount: -0.08),
    ],
    tags: TagSet(effects: {EffectTag.mobility}),
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.backpackOfGlass,
    name: 'Relic: Glass Satchel',
    iconId: 'item_backpack_of_glass',
    description: 'Blessing: +Pickup Radius / Burden: -Max HP',
    flavorText: 'Carry more, breathe less.',
    modifiers: [
      StatModifier(stat: StatId.pickupRadiusPercent, amount: 0.12),
      StatModifier(stat: StatId.maxHp, amount: -0.08),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.fieldRations,
    name: 'Vow of Plain Meals',
    iconId: 'item_field_rations',
    description: 'Blessing: +HP Regen / Burden: -Damage',
    flavorText: 'Nutritious, if you ignore the taste.',
    modifiers: [
      StatModifier(stat: StatId.hpRegen, amount: 4, kind: ModifierKind.flat),
      StatModifier(stat: StatId.damagePercent, amount: -0.03),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.sturdyStitching,
    name: 'Relic: Consecrated Thread',
    iconId: 'item_sturdy_stitching',
    description: 'Blessing: +Max HP / Burden: -Dodge Chance',
    flavorText: 'It holds together, unlike your schedule.',
    modifiers: [
      StatModifier(stat: StatId.maxHp, amount: 0.04),
      StatModifier(stat: StatId.dodgeChance, amount: -0.03),
    ],
    rarity: ItemRarity.common,
  ),
  ItemDef(
    id: ItemId.primerCoil,
    name: 'Rite of First Spark',
    iconId: 'item_primer_coil',
    description: 'Blessing: +Damage / Burden: -Attack Speed',
    flavorText: 'It starts fights faster than it ends them.',
    modifiers: [
      StatModifier(stat: StatId.damagePercent, amount: 0.04),
      StatModifier(stat: StatId.attackSpeed, amount: -0.03),
    ],
    rarity: ItemRarity.common,
  ),
];

const List<ItemDef> uncommonItems = [
  ItemDef(
    id: ItemId.slowCooker,
    name: 'Rite of Slow Fire',
    iconId: 'item_slow_cooker',
    description: 'Blessing: +DOT Damage & Duration / Burden: -Damage',
    flavorText: 'The stew wins, eventually.',
    modifiers: [
      StatModifier(stat: StatId.dotDamagePercent, amount: 0.25),
      StatModifier(stat: StatId.dotDurationPercent, amount: 0.2),
      StatModifier(stat: StatId.damagePercent, amount: -0.12),
    ],
    tags: TagSet(effects: {EffectTag.dot}),
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.wideLens,
    name: 'Relic: Wide Lens',
    iconId: 'item_wide_lens',
    description: 'Blessing: +Area Size & Field of View / Burden: -Attack Speed',
    flavorText: 'You see more, shoot less.',
    modifiers: [
      StatModifier(stat: StatId.aoeSize, amount: 0.25),
      StatModifier(stat: StatId.fieldOfView, amount: 0.1),
      StatModifier(stat: StatId.attackSpeed, amount: -0.15),
    ],
    tags: TagSet(effects: {EffectTag.aoe}),
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.briarCharm,
    name: 'Vow of Briars',
    iconId: 'item_briar_charm',
    description: 'Blessing: +Status Duration & Potency / Burden: -Dodge Chance',
    flavorText: 'The vines are loyal and slow walkers.',
    modifiers: [
      StatModifier(stat: StatId.statusDurationPercent, amount: 0.25),
      StatModifier(stat: StatId.statusPotencyPercent, amount: 0.2),
      StatModifier(stat: StatId.dodgeChance, amount: -0.1),
    ],
    tags: TagSet(elements: {ElementTag.earth, ElementTag.wood}),
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.vampiricSeal,
    name: 'Vow of the Leech',
    iconId: 'item_vampiric_seal',
    description: 'Blessing: +Absolution / Burden: -Max HP',
    flavorText: 'You borrow health with a very short due date.',
    modifiers: [
      StatModifier(stat: StatId.absolution, amount: 0.15),
      StatModifier(stat: StatId.maxHp, amount: -0.15),
    ],
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.gamblersDie,
    name: 'Clause: Second Chance',
    iconId: 'item_gamblers_die',
    description: 'Blessing: +Rerolls / Burden: -Choice Count',
    flavorText: 'The die insists you renegotiate fate.',
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
    name: 'Rite of Rebound Ward',
    iconId: 'item_reactive_shield',
    description: 'Blessing: +Defense / Burden: -Attack Speed',
    flavorText: 'The shield is punctual; your skills are not.',
    modifiers: [
      StatModifier(stat: StatId.defense, amount: 0.2),
      StatModifier(stat: StatId.attackSpeed, amount: -0.15),
    ],
    tags: TagSet(effects: {EffectTag.support}),
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.ritualCandle,
    name: 'Relic: Ritual Candle',
    iconId: 'item_ritual_candle',
    description:
        'Blessing: +Fire DOT & Elemental Damage / Burden: -Water Damage',
    flavorText: 'Smells holy, burns like gossip.',
    modifiers: [
      StatModifier(stat: StatId.dotDamagePercent, amount: 0.2),
      StatModifier(stat: StatId.fireDamagePercent, amount: 0.2),
      StatModifier(stat: StatId.elementalDamagePercent, amount: 0.05),
      StatModifier(stat: StatId.waterDamagePercent, amount: -0.15),
    ],
    tags: TagSet(elements: {ElementTag.fire}),
    rarity: ItemRarity.uncommon,
  ),
  ItemDef(
    id: ItemId.gravelBoots,
    name: 'Vow of Heavy Steps',
    iconId: 'item_gravel_boots',
    description: 'Blessing: +Banishment Force / Burden: -Attack Speed',
    flavorText: 'Every stomp is a sermon.',
    modifiers: [
      StatModifier(stat: StatId.banishmentForce, amount: 0.25),
      StatModifier(stat: StatId.attackSpeed, amount: -0.15),
    ],
    metaUnlockId: MetaUnlockId.gravelBootsPattern,
    rarity: ItemRarity.uncommon,
  ),
];

const List<ItemDef> rareItems = [
  ItemDef(
    id: ItemId.glassCatalyst,
    name: 'Rite of Glass Power',
    iconId: 'item_glass_catalyst',
    description: 'Blessing: +Damage & Flat Damage / Burden: -Defense',
    flavorText: 'Sharp ideas, fragile plan.',
    modifiers: [
      StatModifier(stat: StatId.damagePercent, amount: 0.2),
      StatModifier(
        stat: StatId.flatDamage,
        amount: 1.0,
        kind: ModifierKind.flat,
      ),
      StatModifier(stat: StatId.defense, amount: -0.09),
    ],
    rarity: ItemRarity.rare,
    maxStacks: 1,
  ),
  ItemDef(
    id: ItemId.thermalCoil,
    name: 'Relic: Ember Coil',
    iconId: 'item_thermal_coil',
    description:
        'Blessing: +Fire DOT & Elemental Damage / Burden: -Projectile Damage',
    flavorText: 'Everything burns longer, including your patience.',
    modifiers: [
      StatModifier(stat: StatId.dotDurationPercent, amount: 0.3),
      StatModifier(stat: StatId.fireDamagePercent, amount: 0.2),
      StatModifier(stat: StatId.elementalDamagePercent, amount: 0.08),
      StatModifier(stat: StatId.projectileDamagePercent, amount: -0.18),
    ],
    metaUnlockId: MetaUnlockId.thermalCoilBlueprint,
    tags: TagSet(elements: {ElementTag.fire}, effects: {EffectTag.dot}),
    rarity: ItemRarity.rare,
  ),
  ItemDef(
    id: ItemId.hydraulicStabilizer,
    name: 'Rite of Steady Beam',
    iconId: 'item_hydraulic_stabilizer',
    description: 'Blessing: +Beam Damage & Area Size / Burden: -Dodge Chance',
    flavorText: 'Beams hold steady; you do not.',
    modifiers: [
      StatModifier(stat: StatId.beamDamagePercent, amount: 0.3),
      StatModifier(stat: StatId.aoeSize, amount: 0.2),
      StatModifier(stat: StatId.dodgeChance, amount: -0.12),
    ],
    metaUnlockId: MetaUnlockId.hydraulicStabilizerPermit,
    tags: TagSet(deliveries: {DeliveryTag.beam}),
    rarity: ItemRarity.rare,
  ),
  ItemDef(
    id: ItemId.sporeSatchel,
    name: 'Relic: Spore Satchel',
    iconId: 'item_spore_satchel',
    description: 'Blessing: +Poison DOT & Defense / Burden: -Healing Received',
    flavorText: 'The spores are friendly; your healer is not.',
    modifiers: [
      StatModifier(stat: StatId.dotDamagePercent, amount: 0.25),
      StatModifier(stat: StatId.defense, amount: 0.12),
      StatModifier(stat: StatId.healingReceivedPercent, amount: -0.25),
    ],
    metaUnlockId: MetaUnlockId.sporeSatchelKit,
    tags: TagSet(elements: {ElementTag.poison}, effects: {EffectTag.dot}),
    rarity: ItemRarity.rare,
  ),
  ItemDef(
    id: ItemId.serratedEdge,
    name: 'Relic: Serrated Edge',
    iconId: 'item_serrated_edge',
    description:
        'Blessing: +Melee Damage & DOT Damage / Burden: -Projectile Damage',
    flavorText: 'It cuts cleanly and argues with bows.',
    modifiers: [
      StatModifier(stat: StatId.meleeDamagePercent, amount: 0.25),
      StatModifier(stat: StatId.dotDamagePercent, amount: 0.2),
      StatModifier(stat: StatId.projectileDamagePercent, amount: -0.25),
    ],
    metaUnlockId: MetaUnlockId.serratedEdgeRecipe,
    tags: TagSet(effects: {EffectTag.dot}),
    rarity: ItemRarity.rare,
  ),
  ItemDef(
    id: ItemId.mercyCharm,
    name: 'Vow of Mercy',
    iconId: 'item_mercy_charm',
    description: 'Blessing: +Healing Received & HP Regen / Burden: -Damage',
    flavorText: 'You recover faster than you resolve anything.',
    modifiers: [
      StatModifier(stat: StatId.healingReceivedPercent, amount: 0.3),
      StatModifier(stat: StatId.damagePercent, amount: -0.2),
      StatModifier(stat: StatId.hpRegen, amount: 8, kind: ModifierKind.flat),
    ],
    metaUnlockId: MetaUnlockId.mercyCharmVow,
    tags: TagSet(effects: {EffectTag.support}),
    rarity: ItemRarity.rare,
  ),
];

const List<ItemDef> epicItems = [
  ItemDef(
    id: ItemId.volatileMixture,
    name: 'Rite of Volatile Mix',
    iconId: 'item_volatile_mixture',
    description: 'Blessing: +Explosion & Elemental Damage / Burden: -Defense',
    flavorText: 'Spectacular results, questionable safety.',
    modifiers: [
      StatModifier(stat: StatId.explosionDamagePercent, amount: 0.4),
      StatModifier(stat: StatId.fireDamagePercent, amount: 0.2),
      StatModifier(stat: StatId.elementalDamagePercent, amount: 0.1),
      StatModifier(
        stat: StatId.flatElementalDamage,
        amount: 1.2,
        kind: ModifierKind.flat,
      ),
      StatModifier(stat: StatId.defense, amount: -0.12),
    ],
    tags: TagSet(elements: {ElementTag.fire}),
    rarity: ItemRarity.epic,
    maxStacks: 1,
  ),
  ItemDef(
    id: ItemId.moltenBuckle,
    name: 'Relic: Molten Buckle',
    iconId: 'item_molten_buckle',
    description: 'Blessing: +Explosion & Fire Damage / Burden: -Defense',
    flavorText: 'Fashioned for ritual belts and accidental fireworks.',
    modifiers: [
      StatModifier(stat: StatId.explosionDamagePercent, amount: 0.35),
      StatModifier(stat: StatId.fireDamagePercent, amount: 0.25),
      StatModifier(stat: StatId.elementalDamagePercent, amount: 0.1),
      StatModifier(stat: StatId.defense, amount: -0.14),
    ],
    metaUnlockId: MetaUnlockId.moltenBuckleForge,
    tags: TagSet(elements: {ElementTag.fire}),
    rarity: ItemRarity.epic,
    maxStacks: 1,
  ),
];

const List<ItemDef> itemDefs = [
  ...commonItems,
  ...uncommonItems,
  ...rareItems,
  ...epicItems,
];

final Map<ItemId, ItemDef> itemDefsById = Map.unmodifiable({
  for (final def in itemDefs) def.id: def,
});
