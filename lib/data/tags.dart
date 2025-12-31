enum ElementTag { fire, water, earth, wind, poison, steel, wood }

enum EffectTag { aoe, dot, support, debuff, mobility }

enum DeliveryTag { projectile, beam, melee, aura, ground }

enum Faction { demons, angels }

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

enum EnemyVariant { base, champion }

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

  bool get isEmpty => elements.isEmpty && effects.isEmpty && deliveries.isEmpty;
  bool get isNotEmpty => !isEmpty;

  bool equals(TagSet other) {
    return elements.length == other.elements.length &&
        effects.length == other.effects.length &&
        deliveries.length == other.deliveries.length &&
        elements.containsAll(other.elements) &&
        effects.containsAll(other.effects) &&
        deliveries.containsAll(other.deliveries);
  }

  TagSet merge(TagSet other) {
    if (other.isEmpty) {
      return this;
    }
    return TagSet(
      elements: {...elements, ...other.elements},
      effects: {...effects, ...other.effects},
      deliveries: {...deliveries, ...other.deliveries},
    );
  }
}
