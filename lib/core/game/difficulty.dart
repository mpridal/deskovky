/// Robot strength for a whole game (spec 5.7).
enum Difficulty { easy, medium, hard }

/// Pause before a robot's move, so children can follow it (spec 5.7.1).
enum RobotSpeed {
  slow(Duration(milliseconds: 1200)),
  normal(Duration(milliseconds: 600)),
  fast(Duration(milliseconds: 250));

  const RobotSpeed(this.delay);

  final Duration delay;
}
