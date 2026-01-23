import 'package:flame/extensions.dart';

import '../data/ids.dart';

enum SummonKind { processionIdol, vigilLantern, guardianOrb, menderOrb, mine }

class SummonState {
  SummonState() : position = Vector2.zero(), velocity = Vector2.zero();

  final Vector2 position;
  final Vector2 velocity;
  SummonKind kind = SummonKind.processionIdol;
  SkillId sourceSkillId = SkillId.fireball;
  double radius = 8;
  double orbitAngle = 0;
  double orbitRadius = 0;
  double orbitSpeed = 0;
  double moveSpeed = 0;
  double damagePerSecond = 0;
  double projectileDamage = 0;
  double projectileSpeed = 0;
  double projectileRadius = 0;
  double range = 0;
  double lifespan = 0;
  double age = 0;
  double attackCooldown = 0;
  double attackTimer = 0;
  double healingPerSecond = 0;
  double triggerRadius = 0;
  double blastRadius = 0;
  double blastDamage = 0;
  double armDuration = 0;
  bool active = false;

  void reset({
    required SummonKind kind,
    required SkillId sourceSkillId,
    required Vector2 position,
    double radius = 8,
    double orbitAngle = 0,
    double orbitRadius = 0,
    double orbitSpeed = 0,
    double moveSpeed = 0,
    double damagePerSecond = 0,
    double projectileDamage = 0,
    double projectileSpeed = 0,
    double projectileRadius = 0,
    double range = 0,
    double lifespan = 4,
    double attackCooldown = 0,
    double healingPerSecond = 0,
    double triggerRadius = 0,
    double blastRadius = 0,
    double blastDamage = 0,
    double armDuration = 0,
  }) {
    this.kind = kind;
    this.sourceSkillId = sourceSkillId;
    this.position.setFrom(position);
    this.radius = radius;
    this.orbitAngle = orbitAngle;
    this.orbitRadius = orbitRadius;
    this.orbitSpeed = orbitSpeed;
    this.moveSpeed = moveSpeed;
    this.damagePerSecond = damagePerSecond;
    this.projectileDamage = projectileDamage;
    this.projectileSpeed = projectileSpeed;
    this.projectileRadius = projectileRadius;
    this.range = range;
    this.lifespan = lifespan;
    this.attackCooldown = attackCooldown;
    attackTimer = attackCooldown;
    this.healingPerSecond = healingPerSecond;
    this.triggerRadius = triggerRadius;
    this.blastRadius = blastRadius;
    this.blastDamage = blastDamage;
    this.armDuration = armDuration;
    age = 0;
    active = true;
    velocity.setZero();
  }
}
