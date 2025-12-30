import '../data/ids.dart';
import 'enemy_state.dart';

class EnemyPool {
  EnemyPool({int initialCapacity = 32})
    : _inactive = List.generate(
        initialCapacity,
        (_) => EnemyState(id: EnemyId.imp),
      ),
      _active = [];

  final List<EnemyState> _inactive;
  final List<EnemyState> _active;

  List<EnemyState> get active => _active;

  EnemyState acquire(EnemyId id) {
    final state = _inactive.isNotEmpty
        ? _inactive.removeLast()
        : EnemyState(id: id);
    _active.add(state);
    return state;
  }

  void release(EnemyState state) {
    state.active = false;
    _active.remove(state);
    _inactive.add(state);
  }
}
