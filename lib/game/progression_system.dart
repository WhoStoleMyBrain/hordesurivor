import '../data/ids.dart';
import '../data/progression_track_defs.dart';

class ProgressionGain {
  const ProgressionGain({required this.trackId, required this.levelsGained});

  final ProgressionTrackId trackId;
  final int levelsGained;
}

class ProgressionTrackState {
  ProgressionTrackState({required this.def, int startingLevel = 1})
    : _startingLevel = startingLevel,
      level = startingLevel {
    currencyToNext = def.levelCurve.xpForLevel(level);
  }

  final ProgressionTrackDef def;
  final int _startingLevel;

  int level;
  int currentCurrency = 0;
  int currencyToNext = 0;

  int addCurrency(int amount) {
    if (amount <= 0) {
      return 0;
    }
    currentCurrency += amount;
    var levelsGained = 0;
    while (currentCurrency >= currencyToNext) {
      currentCurrency -= currencyToNext;
      level += 1;
      currencyToNext = def.levelCurve.xpForLevel(level);
      levelsGained += 1;
    }
    return levelsGained;
  }

  void reset() {
    level = _startingLevel;
    currentCurrency = 0;
    currencyToNext = def.levelCurve.xpForLevel(level);
  }
}

class ProgressionSystem {
  ProgressionSystem({int startingLevel = 1})
    : _tracks = {
        for (final def in progressionTrackDefs)
          def.id: ProgressionTrackState(def: def, startingLevel: startingLevel),
      } {
    _tracksByCurrency = {
      for (final def in progressionTrackDefs) def.currencyId: _tracks[def.id]!,
    };
  }

  final Map<ProgressionTrackId, ProgressionTrackState> _tracks;
  late final Map<CurrencyId, ProgressionTrackState> _tracksByCurrency;

  ProgressionTrackState trackForId(ProgressionTrackId trackId) {
    return _tracks[trackId]!;
  }

  ProgressionGain? addCurrency(CurrencyId currencyId, int amount) {
    final track = _tracksByCurrency[currencyId];
    if (track == null) {
      return null;
    }
    final levelsGained = track.addCurrency(amount);
    if (levelsGained <= 0) {
      return null;
    }
    return ProgressionGain(trackId: track.def.id, levelsGained: levelsGained);
  }

  void reset() {
    for (final track in _tracks.values) {
      track.reset();
    }
  }
}
