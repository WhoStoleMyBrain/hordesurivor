import 'effect_state.dart';

class EffectPool {
  EffectPool({int initialCapacity = 24})
    : _inactive = List.generate(initialCapacity, (_) => EffectState()),
      _active = [];

  final List<EffectState> _inactive;
  final List<EffectState> _active;

  List<EffectState> get active => _active;

  EffectState acquire() {
    final effect = _inactive.isEmpty ? EffectState() : _inactive.removeLast();
    _active.add(effect);
    return effect;
  }

  void release(EffectState effect) {
    effect.active = false;
    _active.remove(effect);
    _inactive.add(effect);
  }
}
