import 'dart:ui';

import 'package:flutter/foundation.dart';

@immutable
class VirtualStickState {
  const VirtualStickState({
    required this.active,
    required this.origin,
    required this.delta,
    required this.deadZone,
    required this.maxRadius,
  });

  const VirtualStickState.inactive({
    required this.deadZone,
    required this.maxRadius,
  }) : active = false,
       origin = Offset.zero,
       delta = Offset.zero;

  final bool active;
  final Offset origin;
  final Offset delta;
  final double deadZone;
  final double maxRadius;

  double get magnitude => delta.distance;

  Offset get clampedDelta {
    if (maxRadius <= 0) {
      return Offset.zero;
    }
    final length = magnitude;
    if (length <= maxRadius || length == 0) {
      return delta;
    }
    final scale = maxRadius / length;
    return Offset(delta.dx * scale, delta.dy * scale);
  }

  VirtualStickState copyWith({bool? active, Offset? origin, Offset? delta}) {
    return VirtualStickState(
      active: active ?? this.active,
      origin: origin ?? this.origin,
      delta: delta ?? this.delta,
      deadZone: deadZone,
      maxRadius: maxRadius,
    );
  }
}
