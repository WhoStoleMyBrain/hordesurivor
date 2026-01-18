class StressStatsSnapshot {
  const StressStatsSnapshot({
    required this.frameCount,
    required this.averageFps,
    required this.minFps,
    required this.maxFps,
    required this.averageFrameMs,
    required this.worstFrameMs,
    required this.slowFrameCount,
    required this.slowFrameThresholdMs,
  });

  final int frameCount;
  final double averageFps;
  final double minFps;
  final double maxFps;
  final double averageFrameMs;
  final double worstFrameMs;
  final int slowFrameCount;
  final double slowFrameThresholdMs;
}

class StressStatsTracker {
  static const double _slowFrameThresholdMs = 33.4;

  int _frameCount = 0;
  double _fpsSum = 0;
  double _frameTimeSum = 0;
  double _minFps = double.infinity;
  double _maxFps = 0;
  double _worstFrameMs = 0;
  int _slowFrameCount = 0;

  void recordFrame(double dtSeconds) {
    if (dtSeconds <= 0) {
      return;
    }
    final fps = 1 / dtSeconds;
    final frameMs = dtSeconds * 1000;
    _frameCount += 1;
    _fpsSum += fps;
    _frameTimeSum += frameMs;
    if (fps < _minFps) {
      _minFps = fps;
    }
    if (fps > _maxFps) {
      _maxFps = fps;
    }
    if (frameMs > _worstFrameMs) {
      _worstFrameMs = frameMs;
    }
    if (frameMs >= _slowFrameThresholdMs) {
      _slowFrameCount += 1;
    }
  }

  StressStatsSnapshot snapshot() {
    if (_frameCount == 0) {
      return const StressStatsSnapshot(
        frameCount: 0,
        averageFps: 0,
        minFps: 0,
        maxFps: 0,
        averageFrameMs: 0,
        worstFrameMs: 0,
        slowFrameCount: 0,
        slowFrameThresholdMs: _slowFrameThresholdMs,
      );
    }
    return StressStatsSnapshot(
      frameCount: _frameCount,
      averageFps: _fpsSum / _frameCount,
      minFps: _minFps.isFinite ? _minFps : 0,
      maxFps: _maxFps,
      averageFrameMs: _frameTimeSum / _frameCount,
      worstFrameMs: _worstFrameMs,
      slowFrameCount: _slowFrameCount,
      slowFrameThresholdMs: _slowFrameThresholdMs,
    );
  }
}
