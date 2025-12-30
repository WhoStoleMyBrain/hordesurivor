class RunSummary {
  RunSummary({
    this.timeAlive = 0,
    this.enemiesDefeated = 0,
    this.xpGained = 0,
    this.damageTaken = 0,
    this.areaName,
  });

  double timeAlive;
  int enemiesDefeated;
  int xpGained;
  double damageTaken;
  String? areaName;

  int get score =>
      timeAlive.round() + enemiesDefeated + xpGained - damageTaken.round();

  void reset() {
    timeAlive = 0;
    enemiesDefeated = 0;
    xpGained = 0;
    damageTaken = 0;
    areaName = null;
  }
}
