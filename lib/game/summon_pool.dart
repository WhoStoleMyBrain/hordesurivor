import 'summon_state.dart';

class SummonPool {
  SummonPool({int initialCapacity = 12})
    : _inactive = List.generate(initialCapacity, (_) => SummonState()),
      _active = [];

  final List<SummonState> _inactive;
  final List<SummonState> _active;

  List<SummonState> get active => _active;

  SummonState acquire() {
    final summon = _inactive.isEmpty ? SummonState() : _inactive.removeLast();
    _active.add(summon);
    return summon;
  }

  void release(SummonState summon) {
    summon.active = false;
    _active.remove(summon);
    _inactive.add(summon);
  }
}
