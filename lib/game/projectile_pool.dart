import 'projectile_state.dart';

class ProjectilePool {
  ProjectilePool({int initialCapacity = 64})
    : _inactive = List.generate(initialCapacity, (_) => ProjectileState()),
      _active = [];

  final List<ProjectileState> _inactive;
  final List<ProjectileState> _active;

  List<ProjectileState> get active => _active;

  ProjectileState acquire() {
    final state = _inactive.isNotEmpty
        ? _inactive.removeLast()
        : ProjectileState();
    _active.add(state);
    return state;
  }

  void release(ProjectileState state) {
    state.active = false;
    _active.remove(state);
    _inactive.add(state);
  }
}
