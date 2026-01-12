import '../data/area_defs.dart';

class StageUpdate {
  const StageUpdate({required this.sectionChanged, required this.milestones});

  final bool sectionChanged;
  final List<StageMilestone> milestones;
}

class StageTimer {
  StageTimer({
    required double duration,
    required List<StageSection> sections,
    List<StageMilestone> milestones = const [],
  }) : _duration = duration,
       _sections = List<StageSection>.from(sections),
       _milestones = _sortedMilestones(milestones) {
    _currentSectionIndex = _resolveSectionIndex(0);
    _nextMilestoneIndex = _resolveMilestoneIndex(0);
  }

  double _duration;
  double _elapsed = 0;
  List<StageSection> _sections;
  List<StageMilestone> _milestones;
  int _currentSectionIndex = 0;
  int _nextMilestoneIndex = 0;

  double get duration => _duration;
  double get elapsed => _elapsed;
  bool get isComplete => _elapsed >= _duration;
  int get sectionCount => _sections.length;
  int get currentSectionIndex => _currentSectionIndex;
  StageSection? get currentSection =>
      _sections.isEmpty ? null : _sections[_currentSectionIndex];
  List<StageMilestone> get milestones => _milestones;
  int get milestoneCount => _milestones.length;

  void reset({
    required double duration,
    required List<StageSection> sections,
    List<StageMilestone> milestones = const [],
  }) {
    _duration = duration;
    _sections = List<StageSection>.from(sections);
    _milestones = _sortedMilestones(milestones);
    _elapsed = 0;
    _currentSectionIndex = _resolveSectionIndex(0);
    _nextMilestoneIndex = _resolveMilestoneIndex(0);
  }

  StageUpdate update(double dt) {
    final previousIndex = _currentSectionIndex;
    final previousElapsed = _elapsed;
    _elapsed = (_elapsed + dt).clamp(0.0, _duration);
    _currentSectionIndex = _resolveSectionIndex(_elapsed);
    final milestones = <StageMilestone>[];
    while (_nextMilestoneIndex < _milestones.length &&
        _milestones[_nextMilestoneIndex].time <= _elapsed) {
      final milestone = _milestones[_nextMilestoneIndex];
      if (milestone.time > previousElapsed) {
        milestones.add(milestone);
      }
      _nextMilestoneIndex++;
    }
    return StageUpdate(
      sectionChanged: previousIndex != _currentSectionIndex,
      milestones: milestones,
    );
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

  int _resolveMilestoneIndex(double time) {
    for (var i = 0; i < _milestones.length; i++) {
      if (_milestones[i].time > time) {
        return i;
      }
    }
    return _milestones.length;
  }

  static List<StageMilestone> _sortedMilestones(
    List<StageMilestone> milestones,
  ) {
    if (milestones.isEmpty) {
      return const [];
    }
    final sorted = List<StageMilestone>.from(milestones);
    sorted.sort((a, b) => a.time.compareTo(b.time));
    return sorted;
  }
}
