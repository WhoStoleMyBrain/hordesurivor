import '../data/area_defs.dart';

class StageTimer {
  StageTimer({required double duration, required List<StageSection> sections})
    : _duration = duration,
      _sections = List<StageSection>.from(sections) {
    _currentSectionIndex = _resolveSectionIndex(0);
  }

  double _duration;
  double _elapsed = 0;
  List<StageSection> _sections;
  int _currentSectionIndex = 0;

  double get duration => _duration;
  double get elapsed => _elapsed;
  bool get isComplete => _elapsed >= _duration;
  int get sectionCount => _sections.length;
  int get currentSectionIndex => _currentSectionIndex;
  StageSection? get currentSection =>
      _sections.isEmpty ? null : _sections[_currentSectionIndex];

  void reset({required double duration, required List<StageSection> sections}) {
    _duration = duration;
    _sections = List<StageSection>.from(sections);
    _elapsed = 0;
    _currentSectionIndex = _resolveSectionIndex(0);
  }

  bool update(double dt) {
    final previousIndex = _currentSectionIndex;
    _elapsed = (_elapsed + dt).clamp(0.0, _duration);
    _currentSectionIndex = _resolveSectionIndex(_elapsed);
    return previousIndex != _currentSectionIndex;
  }

  int _resolveSectionIndex(double time) {
    if (_sections.isEmpty) {
      return 0;
    }
    for (var i = 0; i < _sections.length; i++) {
      final section = _sections[i];
      if (time < section.endTime && time >= section.startTime) {
        return i;
      }
    }
    if (time >= _sections.last.endTime) {
      return _sections.length - 1;
    }
    return 0;
  }
}
