import 'pickup_state.dart';

class PickupPool {
  PickupPool({int initialCapacity = 32})
    : _inactive = List.generate(initialCapacity, (_) => PickupState()),
      _active = [];

  final List<PickupState> _inactive;
  final List<PickupState> _active;

  List<PickupState> get active => _active;

  PickupState acquire() {
    final state = _inactive.isNotEmpty ? _inactive.removeLast() : PickupState();
    _active.add(state);
    return state;
  }

  void release(PickupState state) {
    state.active = false;
    _active.remove(state);
    _inactive.add(state);
  }
}
