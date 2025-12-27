enum ElementTag {
  fire,
  water,
  earth,
  wind,
  poison,
  steel,
  wood,
}

enum EffectTag {
  aoe,
  dot,
  support,
  debuff,
  mobility,
}

enum DeliveryTag {
  projectile,
  beam,
  melee,
  aura,
  ground,
}

enum Faction {
  demons,
  angels,
}

enum EnemyRole {
  chaser,
  ranged,
  spawner,
  disruptor,
  zoner,
  elite,
  exploder,
  supportHealer,
  supportBuffer,
  pattern,
}

class TagSet {
  const TagSet({
    this.elements = const <ElementTag>{},
    this.effects = const <EffectTag>{},
    this.deliveries = const <DeliveryTag>{},
  });

  final Set<ElementTag> elements;
  final Set<EffectTag> effects;
  final Set<DeliveryTag> deliveries;

  bool hasElement(ElementTag tag) => elements.contains(tag);
  bool hasEffect(EffectTag tag) => effects.contains(tag);
  bool hasDelivery(DeliveryTag tag) => deliveries.contains(tag);
}
