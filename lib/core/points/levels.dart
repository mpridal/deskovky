/// Player levels from total points earned (spec 5.6).
const maxLevel = 30;

/// Total points that level [n] needs: 50 · n · (n + 1) / 2.
int pointsForLevel(int n) => 50 * n * (n + 1) ~/ 2;

int levelFor(int totalEarned) {
  var level = 0;
  while (level < maxLevel && totalEarned >= pointsForLevel(level + 1)) {
    level++;
  }
  return level;
}

/// The level, points gathered since it and points the next level needs
/// beyond it (0 at the top level).
({int level, int current, int needed}) levelProgress(int totalEarned) {
  final level = levelFor(totalEarned);
  if (level == maxLevel) return (level: level, current: 0, needed: 0);
  final from = pointsForLevel(level);
  return (level: level, current: totalEarned - from, needed: pointsForLevel(level + 1) - from);
}
