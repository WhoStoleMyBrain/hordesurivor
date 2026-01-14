import 'dart:math' as math;

import 'package:flame/extensions.dart';

import '../data/stat_defs.dart';
import 'stat_sheet.dart';

class PlayerState {
  PlayerState({
    required this.position,
    required double maxHp,
    required double moveSpeed,
    this.invulnerabilityDuration = 0.5,
    this.hitEffectDuration = 0.18,
  }) : hp = maxHp,
       baseInvulnerabilityDuration = invulnerabilityDuration,
       baseHitEffectDuration = hitEffectDuration,
       stats = StatSheet(
         baseValues: {
           StatId.maxHp: maxHp,
           StatId.moveSpeed: moveSpeed,
           StatId.dashSpeed: 720,
           StatId.dashDistance: 120,
           StatId.dashCooldown: 0.9,
           StatId.dashCharges: 2,
           StatId.dashDuration: 0,
           StatId.dashStartOffset: 0,
           StatId.dashEndOffset: 0,
           StatId.dashInvulnerability: 0.18,
           StatId.dashTeleport: 0,
         },
       ),
       velocity = Vector2.zero(),
       movementIntent = Vector2.zero(),
       impulseVelocity = Vector2.zero(),
       dashDirection = Vector2(1, 0),
       dashVelocity = Vector2.zero(),
       lastMovementDirection = Vector2(1, 0);

  final Vector2 position;
  final Vector2 velocity;
  final Vector2 movementIntent;
  final Vector2 impulseVelocity;
  final Vector2 dashDirection;
  final Vector2 dashVelocity;
  final Vector2 lastMovementDirection;
  final StatSheet stats;
  double hp;
  final double baseInvulnerabilityDuration;
  final double baseHitEffectDuration;
  double invulnerabilityDuration;
  double hitEffectDuration;
  double impulseTimeRemaining = 0;
  double deflectTimeRemaining = 0;
  double deflectRadius = 0;
  double invulnerabilityTimeRemaining = 0;
  double hitEffectTimeRemaining = 0;
  double dashTimeRemaining = 0;
  double dashCooldownRemaining = 0;
  double dashEndOffsetDistance = 0;
  bool dashEndOffsetPending = false;
  int dashCharges = 0;
  int dashMaxCharges = 0;

  double get maxHp => math.max(1, stats.value(StatId.maxHp));
  double get moveSpeed => math.max(0, stats.value(StatId.moveSpeed));
  bool get isInvulnerable => invulnerabilityTimeRemaining > 0;
  bool get isDashing => dashTimeRemaining > 0;
  double get hitEffectProgress {
    if (hitEffectDuration <= 0) {
      return 0;
    }
    return (1 - (hitEffectTimeRemaining / hitEffectDuration)).clamp(0, 1);
  }

  void applyModifiers(Iterable<StatModifier> modifiers) {
    stats.addModifiers(modifiers);
    hp = hp.clamp(0, maxHp);
    _syncDashChargeLimits();
  }

  void resetForRun() {
    stats.resetModifiers();
    hp = maxHp;
    velocity.setZero();
    movementIntent.setZero();
    impulseVelocity.setZero();
    dashDirection.setValues(1, 0);
    dashVelocity.setZero();
    lastMovementDirection.setValues(1, 0);
    impulseTimeRemaining = 0;
    deflectTimeRemaining = 0;
    deflectRadius = 0;
    invulnerabilityDuration = baseInvulnerabilityDuration;
    hitEffectDuration = baseHitEffectDuration;
    invulnerabilityTimeRemaining = 0;
    hitEffectTimeRemaining = 0;
    dashTimeRemaining = 0;
    dashCooldownRemaining = 0;
    dashEndOffsetDistance = 0;
    dashEndOffsetPending = false;
    dashCharges = 0;
    dashMaxCharges = 0;
    _syncDashChargeLimits(fillCharges: true);
  }

  void step(double dt) {
    _syncDashChargeLimits();
    if (dashCooldownRemaining > 0) {
      dashCooldownRemaining = math.max(0, dashCooldownRemaining - dt);
    }
    if (dashCooldownRemaining == 0 && dashCharges < dashMaxCharges) {
      final dashCooldown = math.max(0.0, stats.value(StatId.dashCooldown));
      if (dashCooldown <= 0) {
        dashCharges = dashMaxCharges;
      } else {
        dashCharges = math.min(dashMaxCharges, dashCharges + 1);
        if (dashCharges < dashMaxCharges) {
          dashCooldownRemaining = dashCooldown;
        }
      }
    }
    if (movementIntent.length2 > 0) {
      lastMovementDirection
        ..setFrom(movementIntent)
        ..normalize();
    }
    if (dashTimeRemaining > 0) {
      position.addScaled(dashVelocity, dt);
      dashTimeRemaining = math.max(0, dashTimeRemaining - dt);
      if (dashTimeRemaining == 0 && dashEndOffsetPending) {
        position.addScaled(dashDirection, dashEndOffsetDistance);
        dashEndOffsetPending = false;
        dashEndOffsetDistance = 0;
      }
    } else {
      velocity.setFrom(movementIntent);
      final lengthSquared = velocity.length2;
      if (lengthSquared > 1) {
        velocity.normalize();
      }
      if (lengthSquared > 0) {
        velocity.scale(moveSpeed);
        position.addScaled(velocity, dt);
      }
      if (impulseTimeRemaining > 0) {
        position.addScaled(impulseVelocity, dt);
      }
    }
    if (impulseTimeRemaining > 0) {
      impulseTimeRemaining = math.max(0, impulseTimeRemaining - dt);
    }
    if (deflectTimeRemaining > 0) {
      deflectTimeRemaining = math.max(0, deflectTimeRemaining - dt);
      if (deflectTimeRemaining == 0) {
        deflectRadius = 0;
      }
    }
    if (invulnerabilityTimeRemaining > 0) {
      invulnerabilityTimeRemaining = math.max(
        0,
        invulnerabilityTimeRemaining - dt,
      );
    }
    if (hitEffectTimeRemaining > 0) {
      hitEffectTimeRemaining = math.max(0, hitEffectTimeRemaining - dt);
    }
  }

  void clampToBounds({required Vector2 min, required Vector2 max}) {
    position.x = position.x.clamp(min.x, max.x);
    position.y = position.y.clamp(min.y, max.y);
  }

  void addImpulse({
    required double dx,
    required double dy,
    required double speed,
    required double duration,
  }) {
    if (speed <= 0 || duration <= 0) {
      return;
    }
    impulseVelocity.setValues(dx, dy);
    if (impulseVelocity.length2 <= 0) {
      return;
    }
    impulseVelocity
      ..normalize()
      ..scale(speed);
    impulseTimeRemaining = math.max(impulseTimeRemaining, duration);
  }

  void startDeflect({required double radius, required double duration}) {
    if (radius <= 0 || duration <= 0) {
      return;
    }
    deflectRadius = math.max(deflectRadius, radius);
    deflectTimeRemaining = math.max(deflectTimeRemaining, duration);
  }

  void registerHit({
    double? invulnerabilityDurationOverride,
    double? hitEffectDurationOverride,
  }) {
    final invulnerability =
        invulnerabilityDurationOverride ?? invulnerabilityDuration;
    if (invulnerability > 0) {
      invulnerabilityTimeRemaining = math.max(
        invulnerabilityTimeRemaining,
        invulnerability,
      );
    }
    final hitDuration = hitEffectDurationOverride ?? hitEffectDuration;
    if (hitDuration > 0) {
      hitEffectTimeRemaining = math.max(hitEffectTimeRemaining, hitDuration);
    }
  }

  bool tryDash() {
    if (dashCharges <= 0 || dashTimeRemaining > 0) {
      return false;
    }
    final dashSpeed = math.max(0.0, stats.value(StatId.dashSpeed)).toDouble();
    final dashDistance = math
        .max(0.0, stats.value(StatId.dashDistance))
        .toDouble();
    final dashCooldown = math
        .max(0.0, stats.value(StatId.dashCooldown))
        .toDouble();
    final dashDuration = stats.value(StatId.dashDuration);
    final dashStartOffset = stats.value(StatId.dashStartOffset);
    final dashEndOffset = stats.value(StatId.dashEndOffset);
    final dashInvulnerability = math.max(
      0.0,
      stats.value(StatId.dashInvulnerability),
    );
    final dashTeleport = stats.value(StatId.dashTeleport);
    if (dashSpeed <= 0 && dashDistance <= 0) {
      return false;
    }

    dashDirection.setFrom(movementIntent);
    if (dashDirection.length2 <= 0) {
      dashDirection.setFrom(lastMovementDirection);
    }
    if (dashDirection.length2 <= 0) {
      dashDirection.setValues(1, 0);
    }
    dashDirection.normalize();
    if (dashStartOffset != 0) {
      position.addScaled(dashDirection, dashStartOffset);
    }
    if (dashTeleport >= 1) {
      _consumeDashCharge(dashCooldown);
      if (dashDistance != 0 || dashEndOffset != 0) {
        position.addScaled(dashDirection, dashDistance + dashEndOffset);
      }
      if (dashInvulnerability > 0) {
        invulnerabilityTimeRemaining = math.max(
          invulnerabilityTimeRemaining,
          dashInvulnerability,
        );
      }
      return true;
    }

    var duration = dashDuration;
    if (duration <= 0 && dashSpeed > 0) {
      duration = dashDistance > 0 ? dashDistance / dashSpeed : 0;
    }
    if (duration <= 0) {
      return false;
    }
    var speed = dashSpeed;
    if (dashDistance > 0) {
      speed = dashDistance / duration;
    } else if (speed <= 0) {
      return false;
    }
    _consumeDashCharge(dashCooldown);
    dashVelocity
      ..setFrom(dashDirection)
      ..scale(speed);
    dashTimeRemaining = duration;
    dashEndOffsetPending = dashEndOffset != 0;
    dashEndOffsetDistance = dashEndOffset;
    impulseTimeRemaining = 0;
    if (dashInvulnerability > 0) {
      invulnerabilityTimeRemaining = math.max(
        invulnerabilityTimeRemaining,
        dashInvulnerability,
      );
    }
    return true;
  }

  void _consumeDashCharge(double dashCooldown) {
    if (dashCharges > 0) {
      dashCharges -= 1;
    }
    if (dashCharges < dashMaxCharges && dashCooldownRemaining <= 0) {
      if (dashCooldown <= 0) {
        dashCharges = dashMaxCharges;
      } else {
        dashCooldownRemaining = dashCooldown;
      }
    }
  }

  void _syncDashChargeLimits({bool fillCharges = false}) {
    final maxCharges = math.max(1, stats.value(StatId.dashCharges).round());
    if (maxCharges != dashMaxCharges) {
      if (maxCharges > dashMaxCharges) {
        dashCharges += maxCharges - dashMaxCharges;
      }
      dashMaxCharges = maxCharges;
    }
    if (fillCharges) {
      dashCharges = dashMaxCharges;
    } else if (dashCharges > dashMaxCharges) {
      dashCharges = dashMaxCharges;
    }
  }
}
